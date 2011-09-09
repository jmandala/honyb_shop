require 'spec_helper'

describe Admin::Fulfillment::SystemCheckController do

  context "authorized user" do
    let(:user) { Factory(:admin_user) }
    before { controller.stub :current_user => user }


    describe "GET 'index'" do
      it "should be successful" do
        get 'index'
        response.should be_success
      end
    end

    describe "GET 'order_check'" do
      it "should be successful" do
        get 'order_check'
        response.should be_success
      end
    end

    describe "GET 'ftp_check'" do
      before(:each) do
        Cdf::Config.set({:cdf_run_mode => :mock})
        get 'ftp_check'
      end

      it "assigns @valid_server" do
        assigns(:valid_server).should_not == nil
      end

      it "assigns @valid_credentials" do
        assigns(:valid_credentials).should == true
      end

      it "assigns @outgoing_files" do
        assigns(:outgoing_files).should == []
      end

      it "assigns @test_files" do
        assigns(:test_files).should == []
      end

      it "assigns @archive_files" do
        assigns(:archive_files).should == []
      end

      it "assigns @incoming_files" do
        assigns(:incoming_files).should == []
      end

      it "should be successful" do
        response.should be_success
      end
    end

    describe "POST 'generate_test_order'" do
      it "has value success" do
        put :generate_test_orders, :scenarios => []
        flash[:error].should == "No orders created"
        response.should be_redirect
      end
      
      it "assigns @orders" do
        put :generate_test_orders, :scenarios => [1, 2, 3]
        assigns(:orders).count.should == 3
      end
    end
  end

end
