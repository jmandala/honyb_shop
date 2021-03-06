class UpdateZoneForIntlPriorityShipping < ActiveRecord::Migration
  def self.up
    intl_shipping = self.intl_shipping_method
    return unless intl_shipping && Zone.intl
    intl_shipping.zone = Zone.intl
    intl_shipping.save!
  end

  def self.intl_shipping_method
    return ShippingMethod.find_by_name('INTL Priority')
  end

  def self.down
    shipping = self.intl_shipping_method
    return unless shipping && Zone.all_us
    shipping.zone = Zone.all_us
    shipping.save!
  end
end
