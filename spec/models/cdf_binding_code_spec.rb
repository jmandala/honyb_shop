require_relative '../spec_helper'

describe CdfBindingCode do

  context "when creating a new instance" do
    before(:all) do
      #noinspection RubyInstanceVariableNamingConvention
      @mass_market = FactoryGirl.build :mass_market
    end

    it "should have a code" do
      @mass_market.code.should == 'M'
    end

    it "should have a name" do
      @mass_market.name.should == 'Mass Market'
    end

    it "should allow access to #other" do
      CdfBindingCode.other_code.should_not == nil
      CdfBindingCode.other_code.name == FactoryGirl.build(:other)
    end


  end


end