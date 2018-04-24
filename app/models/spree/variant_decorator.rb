Spree::Variant.class_eval do
  delegate :bottle_size, :default_case, :default_wholesale_case_price,
           :percent_alcohol, :varietal, :vintage, :volume_amount,
           :volume_unit, to: :product

  def brand_key
    brand = product.taxons.joins(:taxonomy).find_by(spree_taxonomies: { name: 'Brands' })
    brand.brand_key rescue ''
  end

  def product_key
    [sku, option_values_ids].compact.join('-')
  end

  ##
  # Ship Compliant necessary attributes:
  #
  # bottle_size: 750ml
  # default_case: 12
  # default_wholesale_case_price: 670
  # percent_alcohol: 5%
  # varietal: 'Cabernet Sauvignon'
  # vintage: 2003
  # volume_amount: 750
  # volume_unit: milliliter
  ##

  def bottle_size
    product.property('bottle_size')
  end

  def default_case
    product.property('default_case')
  end

  def default_wholesale_case_price
    product.property('default_wholesale_case_price')
  end

  def percent_alcohol
    product.property('percent_alcohol')
  end

  def varietal
    product.property('varietal')
  end

  def vintage
    product.property('vintage')
  end

  def volume_amount
    product.property('volume_amount')
  end

  def volume_unit
    product.property('volume_unit')
  end

  private

  def option_values_ids
    values = option_values.includes(:option_type).sort_by do |option_value|
      option_value.option_type.position
    end

    values.to_a.map! do |ov|
      "#{ov.id}"
    end

    values.any? ? values.join('-') : nil
  end
end
