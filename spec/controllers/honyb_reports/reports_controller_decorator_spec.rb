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

  context "#cols_from_report_def" do
    it "returns column keys" do
      report_def = []
      3.times { |i| report_def << {"key-#{i}" => "val-#{i}"} }

      controller.cols_from_report_def(report_def).should == %W[ key-0 key-1 key-2 ]
    end

    
  end
  
  context "#col_vals_from_report_def" do
    it "returns values from procs" do
      report_def = [{'key' => lambda { |o, l| o.number }}]
      order = Factory.create(:order)
      line_item = Factory.create(:line_item)

      controller.col_vals_from_report_def(report_def, order, line_item).should == {'key' => order.number}
    end
    
    
    
  end
end