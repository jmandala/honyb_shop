require 'spec_helper'

describe Admin::Fulfillment::DashboardController do
  context "authorized user" do
    let(:user) { Factory(:admin_user) }
    before { controller.stub :current_user => user }

    
    describe "GET 'index'" do
      
      it "should be successful" do
        get 'index'
        response.should be_success
      end
      
      it "assigns @po_files" do
        get 'index'
        assigns(:po_files).should_not == nil
        assigns(:po_files).should be_a(Array)
      end
      
      it "assigns @needs_po_count" do
        get 'index'
        
        assigns(:needs_po_count).should_not == nil
        assigns(:needs_po_count).should be_a(Fixnum)
      end 
    end
    
  end

end