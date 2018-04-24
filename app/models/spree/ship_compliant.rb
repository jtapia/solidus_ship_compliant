module Spree
  class ShipCompliant
    extend ActiveModel::Naming
    attr_reader :order, :rates

    SHIPPING_SERVICE = 'UPS'

    def initialize(order = nil)
      @order = order
      @rates = []
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
                        shipment_items: shipment_items,
                        ship_to: address_from_spree_address(order.ship_address)
                      }
                    }
                  }
                }

      begin
        initialize_client
        transaction = ::ShipCompliant::CheckCompliance.of_sales_order(payload)
      rescue ::ShipCompliant::CheckComplianceResult
        return 0
      end

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

    def shipment_items
      items = []

      order.line_items.map do |item|
        items << {
                  shipment_item: {
                    discounts: nil,
                    brand_key: item.variant.brand_key,
                    product_key: item.variant.product_key,
                    product_quantity: item.quantity,
                    product_unit_price: item.price.to_i
                  }
                }
      end

      items
    end

    def initialize_client
      ::ShipCompliant.configure do |c|
        c.partner_key = SolidusShipCompliant::Config.partner_key
        c.username    = SolidusShipCompliant::Config.username
        c.password    = SolidusShipCompliant::Config.password
      end
    end
  end
end
