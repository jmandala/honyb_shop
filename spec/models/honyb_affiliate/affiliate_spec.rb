require "spec_helper"

describe Affiliate do
  let(:affiliate_key) { 'affiliate-id' }

  it "#current should return nil by default" do
    Affiliate.current.should == nil
  end

  context "when params are invalid" do

    it "#init should throw an exception" do
      begin
        Affiliate.init(affiliate_key)
        raise StandardError, "should not get here"
      rescue ActiveRecord::RecordNotFound => e
        Affiliate.has_current?.should == false
        e.message.should == %Q{Couldn't find Affiliate with affiliate_key = #{affiliate_key}}
      end
    end
  end

  context "with the class" do
    it "must be comprised of alpha letter, numbers, underscores, dashes" do
      %w("" "12345" "12345." "12345$" "12345'").each do |key|
        lambda { Affiliate.validate_affiliate_key(key) }.should raise_error(ArgumentError, "Affiliate Key should be 6-30 characters and contain only letters, numbers, underscores or dashes.")
      end

      lambda { Affiliate.validate_affiliate_key("123456") }.should_not raise_error(ArgumentError)
      lambda { Affiliate.validate_affiliate_key("123456-") }.should_not raise_error(ArgumentError)
      lambda { Affiliate.validate_affiliate_key("123456_") }.should_not raise_error(ArgumentError)
    end
  end

  context "when params are valid" do
    before do
      @user = Factory(:user)
      @affiliate = Affiliate.create(:affiliate_key => affiliate_key, :users => [@user])
    end

    it "#init should set the correct affiliate" do
      Affiliate.init(affiliate_key)
      Affiliate.current.should == @affiliate
      Affiliate.has_current?.should == true
    end

    context "model spec" do

      it "affiliate has a users" do
        @affiliate.users.should == [@user]
      end

    end


    context "with orders" do
      before do
        @order = Factory(:order)
      end
      
      it "should have orders" do
        @order.affiliate = @affiliate
        @order.save!
        @affiliate.orders.should == [@order]
      end

    end
  end

end