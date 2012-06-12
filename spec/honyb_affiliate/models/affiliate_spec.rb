require "spec_helper"

describe Affiliate, :type => :model do

  it "#current should return nil by default" do
    Affiliate.current.should == nil
  end
  
end