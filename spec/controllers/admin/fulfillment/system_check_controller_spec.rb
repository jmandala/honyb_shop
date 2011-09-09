require 'spec_helper'

describe Admin::Fulfillment::SystemCheckController do

  context "#authorize_admin" do
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
      it "should be successful" do
        get 'ftp_check'
        response.should be_success
      end
    end
  end

end
