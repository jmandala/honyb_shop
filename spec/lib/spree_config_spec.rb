require_relative '../spec_helper'

describe 'Spree::Config' do
  before(:each) do
    @key = :test_config_key
  end

  after(:each) do
    Spree::Config.set({@key => @value})
    Spree::Config.get(@key).should == @value
    puts "#{@key} = #{Spree::Config.get(@key)}"
  end

  it "should set values once" do
    @value = 'my test configuration'
  end


  it "should set values a second time" do
    @value = 'my test configuration part II'
  end

  it "should set the values a third time" do
    @value = 'my test configuration part III'
  end
end