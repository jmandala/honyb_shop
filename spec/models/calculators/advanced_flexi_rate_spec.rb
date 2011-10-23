require 'spec_helper'

describe Calculator::AdvancedFlexiRate do
  let(:calculator) { Calculator::AdvancedFlexiRate.new }
  context "compute by line items" do
    let(:order) do
      mock_model Order,
                 :line_items => [mock_model(LineItem, :amount => 10, :quantity => 2),
                                 mock_model(LineItem, :amount => 20, :quantity => 3)],
                 :inventory_units => []
    end

    context "compute" do
      it "should compute amount correctly when all fees are 0" do
        calculator.compute(order).round(2).should == 0.0
      end

      it "should compute amount correctly when first_item has a value" do
        calculator.stub :preferred_first_item => 2
        calculator.compute(order).should == 2
      end

      it "should compute amount correctly when additional_items has a value" do
        calculator.stub :preferred_additional_item => 1
        calculator.compute(order).should == 4
      end

      it "should compute amount correctly when additional_items and first_item have values" do
        calculator.stub :preferred_first_item => 2, :preferred_additional_item => 1
        calculator.compute(order).should == 6
      end

      it "should compute amount correctly when additional_items and first_item have values AND max items has value" do
        calculator.stub :preferred_first_item => 2, :preferred_additional_item => 1, :preferred_max_items => 4
        calculator.compute(order).should == 7
      end
    end
  end
  
  context "compute by inventory units" do
    let(:order) do
      mock_model Order,
                 :line_items => [mock_model(LineItem, :amount => 10, :quantity => 2),
                                 mock_model(LineItem, :amount => 20, :quantity => 3)],
                 :inventory_units => [
                  mock_model(InventoryUnit),
                  mock_model(InventoryUnit),
                  mock_model(InventoryUnit),
                  mock_model(InventoryUnit),
                  mock_model(InventoryUnit)
                 ]
    end

    context "compute" do
      it "should compute amount correctly when all fees are 0" do
        calculator.compute(order).should == 0
      end

      it "should compute amount correctly when first_item has a value" do
        calculator.stub :preferred_first_item => 2
        calculator.compute(order).should == 2
      end

      it "should compute amount correctly when additional_items has a value" do
        calculator.stub :preferred_additional_item => 1
        calculator.compute(order).should == 4
      end

      it "should compute amount correctly when additional_items and first_item have values" do
        calculator.stub :preferred_first_item => 2, :preferred_additional_item => 1
        calculator.compute(order).should == 6
      end

      it "should compute amount correctly when additional_items and first_item have values AND max items has value" do
        calculator.stub :preferred_first_item => 2, :preferred_additional_item => 1, :preferred_max_items => 4
        calculator.compute(order).should == 7
      end
    end
  end
end
