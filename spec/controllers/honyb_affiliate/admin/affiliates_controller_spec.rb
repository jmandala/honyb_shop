require 'spec_helper'

describe Admin::AffiliatesController do
  
  let(:user) { Factory(:admin_user) }
  before { controller.stub :current_user => user }  
  
  
  
  it "should display list" do
    get :index
  end
end