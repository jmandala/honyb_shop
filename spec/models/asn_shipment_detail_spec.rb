# This is a poorly implemented test. Too many fixtures, Too hard to determine what's happening
# See cdf_compliance_spec.rb instead
describe AsnShipmentDetail do

  let(:shipping_method) { mock_model(ShippingMethod, :id => 1) }
  let(:shipped_status) { mock_model(AsnOrderStatus, :shipped? => true) }
  let(:asn_shipping_method_code_shipped) { mock_model(AsnShippingMethodCode, :shipping_method => shipping_method) }
  let(:asn_shipment) { mock_model(AsnShipment, :shipment_date => Date.today) }
  let(:asd_shipped) { AsnShipmentDetail.new(:asn_order_status => shipped_status, :asn_shipping_method_code => asn_shipping_method_code_shipped) }
  let(:asd) { AsnShipmentDetail.new(:order => mock_model(Order, :id => 1)) }

  after :each do
    AsnShipmentDetail.all.each &:destroy
  end

  context "default values" do
    it "should have no line item" do
      asd.line_item.should == nil
    end

    it "#order" do
      asd.order.should_not == nil
    end

    it "#inventory_untis" do
      asd.inventory_units.empty?.should == true
    end

    it "#asn_file" do
      asd.asn_file.should == nil
    end

    it "#asn_shipment" do
      asd.asn_shipment.should == nil
    end

    it "#product" do
      asd.product.should == nil
    end

    it "#variant" do
      asd.variant.should == nil
    end

    it "#shipped?" do
      asd.shipped?.should == false
      asd_shipped.shipped?.should == true
    end

    it "#shipping_method" do
      asd.shipping_method.should == nil
      asd_shipped.asn_shipping_method_code.should_not == nil
      asd_shipped.shipping_method.should == shipping_method
    end

    it "#missing_shipment" do
      3.times { AsnShipmentDetail.create }
      AsnShipmentDetail.missing_shipment.count.should == 3
    end

  end

  context "items shipped" do
    let(:variant_1) { mock_model(Variant, :sku => '999', :id => 1) }
    let(:line_item_1) { mock_model(LineItem, :variant => variant_1, :quantity => 1) }
    let(:order) { mock_model(Order, :id => 1, :completed? => true, :canceled? => false, :line_items => [line_item_1]) }
    let(:inventory_unit_1) { InventoryUnit.new(:variant => variant_1, :order => order, :state => 'sold') }
    let(:inventory_unit_2) { InventoryUnit.new(:variant => variant_1, :order => order, :state => 'sold') }
    let(:inventory_units_arel) { [inventory_unit_1] }
    let(:shipment) {
      inventory_unit_1.stub(:cancel!) { true }
      inventory_unit_2.stub(:cancel!) { true }

      mock_model(Shipment,
                 :tracking => '',
                 :inventory_units => inventory_units_arel,
                 :ship => true,
                 :ship! => true)
    }


    let(:asn_shipped) { mock_model(AsnShippingMethodCode, :shipping_method => shipping_method, :code => '00', :description => 'Shipped') }
    let(:asn_slashed) { mock_model(AsnShippingMethodCode, :code => 'S1', :description => 'DC Slash (warehouse)') }


    let(:tracking) { '1234567' }

    let(:expect_shipment_assigned) do
      inventory_units_arel.stub_chain(:sold, :limit, :first) { inventory_unit_1 }
      inventory_units_arel.stub(:all) { [inventory_unit_1, inventory_unit_2] }

      shipment.stub(:shipped_at=).with(Date.today)
      shipment.stub(:state?).with('shipped').and_return(false)
      shipment.stub(:can_ship?).and_return(true)
      shipment.stub(:save!)
      shipment.stub(:tracking=).with(tracking) if tracking

    end

    let(:expect_inventory_assigned) do
      shipment.stub(:save!)
      shipment.stub_chain(:inventory_units, :sold, :limit, :first) { inventory_unit_1 }
    end


    context "single line / single quantity" do

      before :each do
        order.stub(:inventory_units) { mock(Object, :sold => [inventory_unit_1]) }
        Shipment.stub(:count)
      end

      context "all shipped" do

        let(:asd_shipped) { AsnShipmentDetail.new(:order => order,
                                                  :line_item => line_item_1,
                                                  :tracking => tracking,
                                                  :asn_order_status => shipped_status,
                                                  :asn_shipping_method_code => asn_shipped,
                                                  :asn_shipment => asn_shipment,
                                                  :quantity_shipped => 1) }

        let(:available_shipment_sql) { "order_id = #{order.id} AND shipping_method_id = #{shipping_method.id} AND (tracking IS NULL OR tracking = '#{tracking}')" }
        let(:expect_available_shipments) do
          Shipment.stub(:where).with(available_shipment_sql).any_number_of_times { shipment }
          shipment.stub(:order) { shipment }
          shipment.stub(:first) { shipment }
          shipment.stub(:count) { 1 }
          shipment.stub(:state)
          shipment.stub(:adjustment)
          shipment.stub(:update!)
        end


        it "should have available shipments" do
          expect_available_shipments
          asd_shipped.available_shipment.should == shipment
        end

        it "#init_shipment" do
          expect_available_shipments
          expect_shipment_assigned

          asd_shipped.init_shipment.should == shipment
          asd_shipped.inventory_units.should == [inventory_unit_1]
        end

        it "#assign_shipment" do
          expect_available_shipments
          expect_shipment_assigned

          asd_shipped.assign_shipment
          asd_shipped.shipment.should == shipment
        end

        it "#assign_inventory" do
          expect_available_shipments
          expect_shipment_assigned
          expect_inventory_assigned

          asd_shipped.assign_inventory
          asd_shipped.inventory_units.should == [inventory_unit_1]
        end

      end

      context "none shipped" do
        let(:canceled) { AsnOrderStatus.find_by_code('26') }
        let(:asn_slash_code) { AsnSlashCode.find_by_code('I1') }

        let(:asd_canceled) { AsnShipmentDetail.new(:order => order,
                                                   :line_item => line_item_1,
                                                   :asn_order_status => canceled,
                                                   :asn_slash_code => asn_slash_code,
                                                   :asn_shipment => asn_shipment,
                                                   :quantity_shipped => 1) }

        let(:available_shipment_sql) { "order_id = #{order.id} AND shipping_method_id = #{shipping_method.id}" }
        let(:expect_available_shipments) do
          Shipment.stub(:where).with(available_shipment_sql) { shipment }
          shipment.stub(:order) { shipment }
          shipment.stub(:first) { shipment }
          shipment.stub(:count) { 1 }
          shipment.stub(:state)
          shipment.stub(:adjustment)
          shipment.stub(:update!)
        end

        let(:tracking) { nil }

        it "#init_shipment" do
          expect_available_shipments
          expect_shipment_assigned
          expect_inventory_assigned

          Shipment.stub(:where).with("order_id = #{order.id}") { shipment }
          inventory_unit_1.should_receive(:cancel!)
          asd_canceled.init_shipment
        end

      end
    end


    context "single line / multiple quantity" do

      before :each do
        order.stub(:inventory_units) { mock(Object, :sold => [inventory_unit_1, inventory_unit_2]) }
      end

      context "all shipped" do
        let(:asd_shipped) { AsnShipmentDetail.new(:order => order,
                                                  :line_item => line_item_1,
                                                  :tracking => tracking,
                                                  :asn_order_status => shipped_status,
                                                  :asn_shipping_method_code => asn_shipped,
                                                  :asn_shipment => asn_shipment,
                                                  :quantity_shipped => 2) }

        let(:available_shipment_sql) { "order_id = #{order.id} AND shipping_method_id = #{shipping_method.id} AND (tracking IS NULL OR tracking = '#{tracking}')" }
        let(:expect_available_shipments) {
          Shipment.stub(:where).with(available_shipment_sql) { shipment }
          shipment.should_receive(:count) { 1 }
          shipment.should_receive(:order) { shipment }
          shipment.should_receive(:first) { shipment }
        }


        it "should have available shipments" do
          expect_available_shipments
          asd_shipped.available_shipment.should == shipment
        end

        it "#init_shipment" do
          expect_available_shipments
          expect_shipment_assigned
          expect_inventory_assigned

          asd_shipped.init_shipment.should == shipment
          asd_shipped.inventory_units.should == [inventory_unit_1, inventory_unit_2]
        end

        it "#assign_shipment" do
          expect_shipment_assigned

          asd_shipped.assign_shipment
          asd_shipped.shipment.should == shipment
        end

        it "#assign_inventory" do
          expect_inventory_assigned

          asd_shipped.assign_inventory
          asd_shipped.inventory_units.should == [inventory_unit_1, inventory_unit_2]
        end
      end


    end

=begin
    context "multi-line / single quantity" do
      context "one order, one shipment, two AsnShipmentDetails" do
        let(:asd_2) { AsnShipmentDetail.new(:order => order, :tracking => tracking_2, :asn_order_status => shipped, :asn_shipping_method_code => asn_shipping_method_code, :quantity_shipped => 2) }
        let(:tracking_2) { tracking + "123" }
        let(:shipment_2) { mock_model(Shipment, :tracking => tracking_2, :ship => true, :ship! => true) }


        before :each do
          Shipment.stub(:where).with("order_id = #{order.id}\n      AND shipping_method_id = 1\n      AND (tracking IS NULL OR tracking = '#{tracking_2}')") { [shipment, shipment_2] }
          shipment.stub(:tracking=).with(tracking)
          shipment_2.stub(:tracking=).with(tracking_2)
        end


        it "should assign two AsnShipmentDetails to the same shipment when they have the same tracking" do
          asd.init_shipment(tracking).should == shipment
          asd_2.init_shipment(tracking_2).should == shipment_2
        end
      end

    end
=end

    context "multi-line / multiple quantity"

  end

end