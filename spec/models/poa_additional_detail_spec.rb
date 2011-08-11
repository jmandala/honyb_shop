require 'spec_helper'

describe PoaAdditionalDetail do

  context "when creating a new instance" do

    before(:all) do
      @pad = FactoryGirl.create :poa_additional_detail
    end

    it "should have default values" do
      @pad.availability_date.should_not == nil
      @pad.po_number.should_not == nil
    end

  end

end