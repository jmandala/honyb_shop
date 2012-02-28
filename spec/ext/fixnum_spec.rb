require_relative '../spec_helper'

describe Fixnum do
  it "should allow left justified padding formatting" do
    1.ljust_trim(10).should == "1         "
    1.ljust_trim(10, "-").should == "1---------"
  end

end
