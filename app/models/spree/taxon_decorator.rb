Spree::Taxon.class_eval do
  def brand_key
    return '' unless name

    words = name.split(' ')

    if words.count > 1
      words.map(&:chr).join.upcase
    else
      name.chars.first(3).join.upcase
    end
  end
end
