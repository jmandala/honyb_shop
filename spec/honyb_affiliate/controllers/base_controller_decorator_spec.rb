require 'spec_helper'

describe HomeController, :type => :controller do
  let(:honyb_id) { 'the-affiliate-id' }

  before do
    controller.stub :current_user => nil
    Affiliate.current = nil
  end

  it "initializes the affiliate on every request" do
    Affiliate.should_receive(:init).with(nil)

    get :index
    Affiliate.current.should == nil
    request.session[:honyb_id].should == nil
  end

  context "invalid honyb_id" do

    it "should raise error with invalid param data" do
      begin
        get :index, :honyb_id => honyb_id
      rescue ActiveRecord::RecordNotFound => e
        e.message.should == %Q{Couldn't find Affiliate with honyb_id = #{honyb_id}}
      end
    end

    it "should raise error with invalid session data" do
      begin
        request.session[:honyb_id] = honyb_id
        get :index
      rescue ActiveRecord::RecordNotFound => e
        e.message.should == %Q{Couldn't find Affiliate with honyb_id = #{honyb_id}}
      end
    end

  end
  
  context "valid honyb_id" do
    before do
      @affiliate = Affiliate.create(:honyb_id => honyb_id)
    end
    
    it "should get the affiliate with the param data" do
      get :index, :honyb_id => honyb_id
      Affiliate.current.should == @affiliate
      request.session[:honyb_id].should == honyb_id
    end
    
    it "should get the affiliate with the session data" do
      request.session[:honyb_id] = honyb_id
      get :index
      Affiliate.current.should == @affiliate
      request.session[:honyb_id].should == honyb_id
    end
  end
end
