require 'spec_helper'

describe HomeController, :type => :controller do

  context "authorized user" do
    before { controller.stub :current_user => nil }

    it "should do something" do
      get :index
    end
  end
end