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

    def compute_line_item(item)
      if rate.included_in_price
        raise Spree.t(:ship_compliant_alert)
      else
        round_to_two_places(tax_for_item(item))
      end
    end

    def compute_shipment(shipment)
      if rate.included_in_price
        raise Spree.t(:ship_compliant_alert)
      else
        0
      end
    end

    def compute_shipping_rate(shipping_rate)
      if rate.included_in_price
        raise Spree.t(:ship_compliant_alert)
      else
        0
      end
    end

    private

    def tax_for_item(item)
      order = item.order
      item_address = order.tax_address || order.shipping_address

      return 0 unless item_address.present? && calculable.zone.include?(item_address)

      rails_cache_key = cache_key(order, item, item_address)

      Rails.cache.fetch(rails_cache_key, time_to_idle: CACHE_EXPIRATION_DURATION) do
        transaction = Bevv::ShipCompliant.new(order).transaction_from_order
        tax_for_current_item = cache_response(transaction, order, item_address, item)
        tax_for_current_item
      end
    end

    def rate
      calculable
    end

    def round_to_two_places(amount)
      BigDecimal(amount.to_s).round(2, BigDecimal::ROUND_HALF_UP)
    end

    def cache_response(response, order, address, line_item = nil)
      res = nil
      cart_items = response.shipment_sales_tax_rates[0][:product_sales_tax_rates][:product_sales_tax_rate]

      return 0 unless response || cart_items

      cart_items.each do |item|
        next unless item[:@product_key] == line_item.variant.product_key
        res = item[:@sales_tax_due]
        Rails.cache.write(cache_key(order, line_item, address), res, expires_in: CACHE_EXPIRATION_DURATION)
      end

      res
    end

    def cache_key(order, item, address)
      ['Spree::LineItem', order.id, item.id, address.state.id, address.zipcode, item.amount, :amount_to_collect]
    end
  end
end
