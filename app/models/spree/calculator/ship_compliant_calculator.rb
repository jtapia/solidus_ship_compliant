require_dependency 'spree/calculator'

module Spree
  class Calculator::ShipCompliantCalculator < Calculator
    CACHE_EXPIRATION_DURATION = 10.minutes

    def self.description
      Spree.t(:ship_compliant_tax)
    end

    def compute_order(order)
      raise 'Spree::ShipCompliant is designed to calculate taxes at the shipment and line-item levels.'
    end

    def compute_shipment_or_line_item(item)
      if rate.included_in_price
        raise 'ShipCompliant cannot calculate inclusive sales taxes.'
      else
        round_to_two_places(tax_for_item(item))
      end
    end

    alias compute_shipment compute_shipment_or_line_item
    alias compute_line_item compute_shipment_or_line_item

    def compute_shipping_rate(shipping_rate)
      if rate.included_in_price
        raise 'ShipCompliant cannot calculate inclusive sales taxes.'
      else
        0
      end
    end

    private

    def tax_for_shipment(shipment)
      order = shipment.order
      return 0 unless tax_address = order.tax_address

      rails_cache_key = cache_key(order, shipment, tax_address)

      Rails.cache.fetch(rails_cache_key, expires_in: CACHE_EXPIRATION_DURATION) do
        Spree::ShipCompliant.new(order, nil, shipment).calculate_tax_for_shipment
      end
    end

    def tax_for_item(item)
      order = item.order
      item_address = order.ship_address || order.billing_address
      # Only calculate tax when we have an address and it's in our jurisdiction
      return 0 unless item_address.present? && calculable.zone.include?(item_address)

      rails_cache_key = cache_key(order, item, item_address)

      # Cache will expire if the order, any of its line items, or any of its shipments change.
      # When the cache expires, we will need to make another API call to ShipCompliant.
      Rails.cache.fetch(rails_cache_key, time_to_idle: CACHE_EXPIRATION_DURATION) do
        # In the case of a cache miss, we recompute the amounts for _all_ the LineItems and Shipments for this Order.
        # TODO An ideal implementation will break the order down by Shipments / Packages
        # and use the actual StockLocation address for each separately, and create Adjustments
        # for the Shipments to reflect tax on shipping.
        transaction = Spree::ShipCompliant.new(order).transaction_from_order
        lookup_cart_items = transaction.lookup.cart_items

        # Now we will loop back through the items and assign them amounts from the lookup.
        # This inefficient method is due to the fact that item_id isn't preserved in the lookup.
        # TODO There may be a way to refactor this,
        # possibly by overriding the ShipCompliant::Responses::Lookup model
        # or the CartItems model.
        index = -1 # array is zero-indexed
        # Retrieve line_items from lookup
        order.line_items.each do |line_item|
          cache_response(transaction, order, item_address, line_item)
          # Rails.cache.write(['ShipCompliantRatesForItem'], lookup_cart_items[index += 1].tax_amount, time_to_idle: 30.minutes)
        end

        order.shipments.each do |shipment|
          cache_response(transaction, order, item_address, line_item)
          # Rails.cache.write(['ShipCompliantRatesForItem'], lookup_cart_items[index += 1].tax_amount, time_to_idle: 30.minutes)
        end

        # Lastly, return the particular rate that we were initially looking for
        Rails.cache.read(['ShipCompliantRatesForItem'])
      end
    end

    def rate
      calculable
    end

    def cache_response(response, order, address, item = nil)
      ## response is set to faciliate testing as to return computed result from API
      ## better to use Rails.cache.fetch for order and wrapping lookup based on line_item id
      res = nil
      response.breakdown.line_items.each do |line_item|
        item_from_db = Spree::LineItem.find_by(id: line_item.id)
        if item && item_from_db.id == item.id
          res = line_item.tax_collectable
        end
        Rails.cache.write(cache_key(order, item_from_db, address), line_item.tax_collectable, expires_in: CACHE_EXPIRATION_DURATION)
      end
      res
    end

    def cache_key(order, item, address)
      if item.is_a?(Spree::LineItem)
        ['Spree::LineItem', order.id, item.id, address.state.id, address.zipcode, item.amount, :amount_to_collect]
      else
        ['Spree::Shipment', order.id, item.id, address.state.id, address.zipcode, item.cost, :amount_to_collect]
      end
    end
  end
end
