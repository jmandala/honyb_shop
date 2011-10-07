describe InventoryUnit do

    let(:variant) { mock_model(Variant, :id => 1) }
    let(:variant_2) { mock_model(Variant, :id => 2) }
    let(:line_item) { mock_model(LineItem, :variant => variant, :quantity => 5) }
    let(:order) { mock_model(Order, :line_items => [line_item], :inventory_units => [], :shipments => mock('shipments'), :completed? => true) }

    context "#self.sold" do

      before :each do
        @inventory_unit_1 = InventoryUnit.create(:state => "shipped", :variant => variant)
        @inventory_unit_2 = InventoryUnit.create(:state => "sold", :variant => variant)
        @inventory_unit_3 = InventoryUnit.create(:state => "sold", :variant => variant_2)
        @inventory_unit_4 = InventoryUnit.create(:state => "sold", :variant => variant_2)
      end

      after :all do
        InventoryUnit.all.each &:destroy
      end

      it "should return sold inventory" do

        InventoryUnit.all.count.should == 4
        InventoryUnit.sold.count.should == 3
        puts InventoryUnit.sold(variant).to_sql
        InventoryUnit.sold(variant).should == [@inventory_unit_2]
        InventoryUnit.sold(variant_2).should == [@inventory_unit_3, @inventory_unit_4]
      end
    end


end