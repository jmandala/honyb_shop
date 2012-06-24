require 'spec_helper'

describe Admin::ReportsController do

  let(:user) { Factory(:admin_user) }
  before { controller.stub :current_user => user }
  
  it "should have the sales_details report" do
    controller.class::AVAILABLE_REPORTS[:sales_detail].should == nil
    controller.add_own
    controller.class::AVAILABLE_REPORTS[:sales_detail].should_not == nil
  end

  describe "GET sales_detail" do
    it "it assigns @orders" do
      get :sales_detail
      assigns(:orders).should_not == nil
    end
  end

end