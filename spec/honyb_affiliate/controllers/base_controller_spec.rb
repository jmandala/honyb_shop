require 'spec_helper'

describe HomeController, :type => :controller do
  before do
    controller.stub :current_user => nil
    @affiliate = mock_model('Affiliate')
    Affiliate.stub(:current => nil)
    Affiliate.should_receive(:init).with(kind_of(Hash), kind_of(Hash))
  end

  it "initializes the affiliate on every request" do
    get :index
    Affiliate.current.should == nil
  end
end
