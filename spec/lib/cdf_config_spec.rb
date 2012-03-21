require_relative '../spec_helper'

describe Cdf::Config do

  before :all do
    Cdf::Config.init_from_config(:overwrite)
  end

  before :each do
    @key = :test_config_key
  end

  context "when setting values" do

    after :each do
      Cdf::Config.set({@key => @value})
      Cdf::Config[@key].should == @value
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
  
  it "should have run modes" do
    Cdf::Config::RUN_MODE.should == [:live, :test, :mock]
  end

  it "should have a run mode set" do
    Cdf::Config[:cdf_run_mode].to_s.should =~ /test|mock/
  end

  it "should be false when the preference is not set" do
    Cdf::Config[:unspecified].should == nil
  end
end