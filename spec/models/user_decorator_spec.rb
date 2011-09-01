require_relative "../spec_helper"

describe 'user_decorator' do
  it "should create a test user for test orders" do
    u = User.compliance_tester!
    u.should_not == nil
    u.email.should == User.COMPLIANCE_EMAIL
  end
end