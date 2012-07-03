Product.class_eval do

  # Required for CDF Integration
  # BN = ISBN10
  # EN = EAN
  # UP = UPC
  def sku_type
    "EN"
  end

  def self.spec_test
    true
  end

  def ingram_product_type
    val = read_attribute(:ingram_product_type)
    val.to_sym unless val.nil?
  end

  def ingram_product_type=(new_type)
    write_attribute :ingram_product_type, new_type.to_s
  end

  def self.product_types
    types = [:book, :hardcover, :digital]
    @types_array = types.map { |type| [type.to_s, type.to_sym] }
  end

end
