namespace :solidus_ship_compliant do
  desc 'Export products to Ship Compliant'
  task :export_products, [:product_ids] => :environment do |_task, args|
    # Export brands in case that were not exported
    Rake::Task['solidus_ship_compliant:export_brands'].invoke

    # Get brand and category taxonomies
    brand_taxnomy = Spree::Taxonomy.find_by(name: 'Brand')
    category_taxonomy = Spree::Taxonomy.find_by(name: 'Categories')

    product_list(args.extras).in_groups_of(100) do |product_ids|
      # Create Ship Compliant product per Spree::Product variants
      Spree::Product.where(id: product_ids).each do |product|
        brand_taxon = product.taxons.where(taxonomy: brand_taxnomy).first
        category_taxon = product.taxons.where(taxonomy: category_taxonomy).first

        product.variants.each do |variant|
          result = ShipCompliant::AddUpdateProduct.product({
            bottle_size_ms: variant.bottle_size,
            brand_key: brand_taxon.brand_key,
            default_case: variant.default_case || '12',
            default_wholesale_case_price: variant.default_wholesale_case_price || '270',
            description: variant.description || 'Denver Snow Flake Cab 2013',
            percent_alcohol: variant.percent_alcohol || '14.1',
            product_distribution: 'Both',
            product_key: variant.product_key,
            product_type: category_taxon.name, # [Wine, Beer, Cider]
            unit_price: variant.price.to_f,
            varietal: variant.varietal || 'Cabernet Sauvignon',
            vintage: variant.vintage || 2013,
            volume_amount: variant.volumne_amount || 750,
            volume_unit: variant.volume_unit || 'milliliter',
          }, update_mode: 'IgnoreExisting')

          if result.success?
            puts "Product #{variant.name} added successfully."
          else
            result.errors.each do |error|
              puts error.message
            end
          end
        end
      end
    end
  end

  desc 'Export brands to Ship Compliant'
  task export_brands: :environment do
    # Get brand taxonomy and taxons
    taxonomy = Spree::Taxonomy.find_by(name: 'Brand')
    taxons = taxonomy.root.children

    taxons.each do |taxon|
      result = ShipCompliant::AddUpdateBrand.brand({
        key: taxon.brand_key,
        name: taxon.name,
        this_brand_is_bottled_by_a_third_party: true,
        this_brand_is_produced_by_a_third_party: true,
        this_brand_operates_under_a_trade_name: false,
        this_brand_was_acquired_from_a_third_party: false
      })

      if result.success?
        puts "Brand #{taxon.name} added successfully."
      else
        result.errors.each do |error|
          puts error.message
        end
      end
    end
  end

  def product_list(sku_list)
    sku_list.present? &&
      Spree::Product.joins(:master).where("spree_variants.sku IN (?)", sku_list) ||
      Spree::Product.joins(:master)
  end
end