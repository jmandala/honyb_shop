require "spec_helper"

describe Affiliate, :type => :model do
  let(:honyb_id) { 'affiliate-id' }

  it "#current should return nil by default" do
    Affiliate.current.should == nil
  end

  context "when params are invalid" do

    it "#init should throw an exception" do
      begin
        Affiliate.init(honyb_id)
        raise StandardError, "should not get here"
      rescue ActiveRecord::RecordNotFound => e
        Affiliate.has_current?.should == false
        e.message.should == %Q{Couldn't find Affiliate with honyb_id = #{honyb_id}}
      end
    end
  end

  context "when params are valid" do
    before do     
      @user =  Factory(:user)
      @affiliate = Affiliate.create(:honyb_id => honyb_id, :users => [@user])
    end

    it "#init should set the correct affiliate" do
      Affiliate.init(honyb_id)
      Affiliate.current.should == @affiliate
      Affiliate.has_current?.should == true
    end

    context "model spec" do

      it "affiliate has a users" do
        @affiliate.users.should == [@user]
      end
      
    end

  end

end