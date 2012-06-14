require "spec_helper"

describe User, :type => :model do

  before do
    @user = Factory(:user)
    @affiliate = Affiliate.create(:honyb_id => String.random(10), :users => [@user])
  end

  it "has an affiliate" do
    @user.affiliate.should == @affiliate
  end

end