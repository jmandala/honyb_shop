require 'spec_helper'

describe 'user_decorator' do
  
  let(:user) { User.new }
  
  it "should specify the compliance user" do
    User::COMPLIANCE_EMAIL.should == 'compliance.test@honyb.com'
  end
  
  it "should recognize compliance users" do
    user.compliance_tester?.should == false
    
    tester = User.compliance_tester!
    tester.compliance_tester?.should == true
  end

  it "should set password confirmation automatically" do
    
    user.email = 'test@example.com'
    user.password = 'password'
    user.save!
    
    user.password_confirmation.should == user.password
  end
  
end