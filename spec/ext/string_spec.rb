require_relative '../spec_helper'

describe String do
  it "should string dashes" do
    'string-with-dashes'.no_dashes.should == 'stringwithdashes'
  end

end
