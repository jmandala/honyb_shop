require_relative '../spec_helper'

describe String do
  it "should string dashes" do
    'string-with-dashes'.no_dashes.should == 'stringwithdashes'
  end

  it "should allow left justified padding formatting" do
    "abc".ljust_trim(10).should == "abc       "
    "abc".ljust_trim(10, "-").should == "abc-------"
  end
  
end
