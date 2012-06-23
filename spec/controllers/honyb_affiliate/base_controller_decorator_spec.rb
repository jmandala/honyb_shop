require 'spec_helper'

describe HomeController, :type => :controller do
  let(:affiliate_key) { 'the-affiliate-id' }

  before do
    controller.stub :current_user => nil
    Affiliate.current = nil
  end

  it "initializes the affiliate on every request" do
    Affiliate.should_receive(:init).with(nil)

    get :index
    Affiliate.current.should == nil
    request.session[:affiliate_key].should == nil
  end

  context "invalid affiliate_key" do

    it "should raise error with invalid param data" do
      begin
        get :index, :affiliate_key => affiliate_key
      rescue ActiveRecord::RecordNotFound => e
        e.message.should == %Q{Couldn't find Affiliate with affiliate_key = #{affiliate_key}}
      end
    end

    it "should raise error with invalid session data" do
      begin
        request.session[:affiliate_key] = affiliate_key
        get :index
      rescue ActiveRecord::RecordNotFound => e
        e.message.should == %Q{Couldn't find Affiliate with affiliate_key = #{affiliate_key}}
      end
    end

  end
  
  context "valid affiliate_key" do
    before do
      @affiliate = Affiliate.create(:affiliate_key => affiliate_key)
    end
    
    it "should get the affiliate with the param data" do
      get :index, :affiliate_key => affiliate_key
      Affiliate.current.should == @affiliate
      request.session[:affiliate_key].should == affiliate_key
    end
    
    it "should get the affiliate with the session data" do
      request.session[:affiliate_key] = affiliate_key
      get :index
      Affiliate.current.should == @affiliate
      request.session[:affiliate_key].should == affiliate_key
    end
  end
end
