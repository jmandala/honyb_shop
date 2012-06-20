require 'spec_helper'

describe AffiliateAssignmentObserver do
  
  context "when there is no current affiliate" do
    it "should not assign it" do
      order = Factory.create(:order)
      order.affiliate.should == nil
    end
  end
  
  context "when there is an affiliate, that is not yet assigned" do
    it "should assign it" do
      affiliate = Factory.create(:affiliate)
      Affiliate.current = affiliate
      order = Factory.create(:order)
      order.affiliate.should == affiliate
    end
  end
  
  context "when there is already an affiliate assigned" do
    it "should not assign the current affiliate" do
      affiliate = Factory.create(:affiliate, :affiliate_key => String.random(10))
      order = Order.new
      order.affiliate = affiliate
      Affiliate.current = Factory.create(:affiliate, :affiliate_key => String.random(10))      
      order.save!
      order.affiliate.should == affiliate
      order.affiliate.should_not == Affiliate.current
    end
  end
  
end