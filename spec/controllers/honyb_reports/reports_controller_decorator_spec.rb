require 'spec_helper'

describe Admin::ReportsController do
  
  it "should have the sales_detils report" do 
    puts Admin::ReportsController::AVAILABLE_REPORTS.to_yaml
    Admin::ReportsController::AVAILABLE_REPORTS[:sales_details].should_not == nil
  end
end