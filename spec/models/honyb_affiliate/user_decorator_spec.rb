require "spec_helper"

describe User do

  before do
    @user = Factory(:user)
    @affiliate = Affiliate.create(:affiliate_key => String.random(10), :users => [@user])
  end

  it "has an affiliate" do
    @user.affiliate.should == @affiliate
  end

  it "has a affiliate_key" do
    @user.affiliate_key.should == @affiliate.affiliate_key
  end
  
end