module Spree
  class ShipCompliant
    extend ActiveModel::Naming
    attr_reader :order, :reimbursement, :shipment

    SHIPPING_SERVICE = 'UPS'

    def initialize(order = nil, reimbursement = nil, shipment = nil)
      @order = order
      @shipment = shipment
      @reimbursement = reimbursement
      @client = client
    end

    def transaction_from_order
      stock_location = order.shipments.first.try(:stock_location) || Spree::StockLocation.active.where('city IS NOT NULL and state_id IS NOT NULL').first
      raise Spree.t(:ensure_one_valid_stock_location) unless stock_location

      payload = {
                  address_option: {
                    ignore_street_level_errors: true,
                    reject_if_address_suggested: 'false'
                  },
                  include_sales_tax_rates: true,
                  sales_order: {
                    bill_to: address_from_spree_address(order.bill_address),
                    customer_key: SolidusShipCompliant::Config.partner_key,
                    sales_order_key: order.number,
                    purchase_date: DateTime.now,
                    order_type: 'Internet',
                    shipments: {
                      shipment: {
                        shipment_status: 'SentToFulfillment',
                        discounts: nil,
                        fulfillment_house: 'InHouse',
                        handling: 0,
                        insured_amount: 0,
                        license_relationship: 'Default',
                        packages: nil,
                        ship_date: DateTime.now,
                        shipping_service: SHIPPING_SERVICE,
                        shipment_items: order.line_items.map do |item|
                                          {
                                            shipment_item: {
                                              discounts: nil,
                                              brand_key: item.variant.sku.split('-').first,
                                              product_key: item.variant.sku.split('-').last,
                                              product_quantity: item.quantity,
                                              product_unit_price: item.price.to_i
                                            }
                                          }
                                        end,
                        ship_to: address_from_spree_address(order.ship_address)
                      }
                    }
                  }
                }

      begin
        transaction = ::ShipCompliant::CheckCompliance.of_sales_order(payload)
      rescue SolidusShipCompliant::Error
      end

      index = -1 # array is zero-indexed
      # Prepare line_items for lookup
      order.line_items.each { |line_item| transaction.cart_items << cart_item_from_item(line_item, index += 1) }
      # Prepare shipments for lookup
      # order.shipments.each { |shipment| transaction.cart_items << cart_item_from_item(shipment, index += 1) }
      transaction
    end

    # Note that this method can take either a Spree::StockLocation (which has address
    # attributes directly on it) or a Spree::Address object
    def address_from_spree_address(address)
      ::ShipCompliant::Address.new(
        first_name: address.first_name,
        last_name:  address.last_name,
        country:    address.country.iso,
        city:       address.city,
        state:      address.try(:state).try(:abbr),
        street1:    address.address1,
        street2:    address.address2,
        zip1:       address.zipcode.try(:[], 0...5)).address
    end

    def cart_item_from_item(item, index)
      case item
      when Spree::LineItem
        ::ShipCompliant::CartItem.new(
          index:    index,
          item_id:  item.try(:variant).try(:sku).present? ? item.try(:variant).try(:sku) : "LineItem #{item.id}",
          tic:      (item.product.tax_cloud_tic || Spree::Config.taxcloud_default_product_tic),
          price:    item.price,
          quantity: item.quantity
        )
      when Spree::Shipment
        ::ShipCompliant::CartItem.new(
          index:    index,
          item_id:  "Shipment #{item.number}",
          tic:      Spree::Config.taxcloud_shipping_tic,
          price:    item.cost,
          quantity: 1
        )
      else
        raise Spree.t(:cart_item_cannot_be_made)
      end
    end

    def shipment_items
      items = []

      order.line_items.each do |item|
        items << {
                  shipment_item: {
                    discounts: nil,
                    brand_key: item.variant.sku.split('-').first,
                    product_key: item.variant.sku.split('-').last,
                    product_quantity: item.quantity,
                    product_unit_price: item.price.to_i
                  }
                }
      end

      items.to_json
    end

    def client
      ::ShipCompliant.configure do |c|
        c.partner_key = SolidusShipCompliant::Config.partner_key
        c.username    = SolidusShipCompliant::Config.username
        c.password    = SolidusShipCompliant::Config.password
      end
    end
  end
end
