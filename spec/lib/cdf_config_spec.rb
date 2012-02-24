require_relative '../spec_helper'

describe Cdf::Config do
  before(:each) do
    @key = :test_config_key
  end

  after(:each) do
      Cdf::Config.set({@key => @value})
      Cdf::Config.get(@key).should == @value
      puts "#{@key} = #{Cdf::Config.get(@key)}"
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
  
  it "should have run modes" do
    Cdf::Config::RUN_MODE.should == [:live, :test, :mock]
  end
  
  it "should have a run mode set" do
    puts Cdf::Config[:cdf_run_mode]
    puts Cdf::Config[].to_yaml
  end
  
  it "should be false when the preference is not set" do
     Cdf::Config[:unspecified].should == nil
  end
end