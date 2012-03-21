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

end
