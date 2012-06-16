require 'spec_helper'

describe Order do
  it "has an affiliate" do
    affiliate = Affiliate.create(:affiliate_key => String.random(6))
    order = Factory.create(:order)
    order.affiliate = affiliate
    order.save!
    order.affiliate.should == affiliate
    affiliate.orders.should == [order]
  end
end