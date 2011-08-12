require 'spec_helper'

describe PoaOrderControlTotal do

  after(:all) do
    PoaFile.all.each { |p| p.destroy }
  end

  context "when creating a new instance" do
    before(:all) do
      #noinspection RubyInstanceVariableNamingConvention
      @p = FactoryGirl.create :poa_order_control_total
    end

    it "should have a poa_order_header" do
      @p.poa_order_header.should_not == nil
    end

    it "should have record code" do
      @p.record_code.should == '59'
    end

    it "should have a record count" do
      @p.record_count.should > 0
    end

    it "should have a total lines in file" do
      @p.total_line_items_in_file.should > 0
    end

    it "should have a total units acknowledged" do
      @p.total_units_acknowledged.should > 0
    end
  end

end