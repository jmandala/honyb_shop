# This is a poorly implemented test. Too many fixtures, Too hard to determine what's happening
# See cdf_compliance_spec.rb instead
describe AsnShipmentDetail do

  let(:shipping_method) { ShippingMethod.new }
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
    let(:product) { Product.new(:price => 10) }
    let(:variant_1) { Variant.new(:sku => '999', :product => product) }
    let(:line_item_1) { LineItem.new(:variant => variant_1, :quantity => 1) }
    let(:order) { mock_model(Order, :id => 1, :completed? => true, :canceled? => false, :line_items => [line_item_1]) }
    let(:order) { Order.new(:completed => true, :canceled => false, :line_items => [line_item_1]) }
    let(:inventory_unit_1) { InventoryUnit.new(:variant => variant_1, :order => order, :state => 'sold') }
    let(:inventory_unit_2) { InventoryUnit.new(:variant => variant_1, :order => order, :state => 'sold') }
    let(:inventory_units_arel) { [inventory_unit_1] }

    let(:shipment) do
      inventory_unit_1.stub(:cancel!) { true }
      inventory_unit_2.stub(:cancel!) { true }
      Shipment.new(:order => order, :shipping_method => shipping_method, :inventory_units => inventory_units_arel)
    end


    let(:shipment) {
      inventory_unit_1.stub(:cancel!) { true }
      inventory_unit_2.stub(:cancel!) { true }

      mock_model(Shipment,
                 :tracking => '',
                 :inventory_units => inventory_units_arel,
                 :ship => true,
                 :ship! => true,
                 :transfer_sold_to_child => self)
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
        @order = Cdf::OrderBuilder.create_for_scenario('single order/single line/single quantity')
      end

      let(:order) { @order }
      let(:shipment) { order.shipments.first }
      let(:line_item) { order.line_items.first }
      let(:shipping_method) { order.shipping_method }
      let(:inventory_unit_1) { shipment.inventory_units.first }
      let(:shipment) { order.shipments.first }

      context "all shipped" do

        let(:asn_shipped) { mock_model(AsnShippingMethodCode, :shipping_method => shipping_method, :code => '00', :description => 'Shipped') }

        let(:asd_shipped) {
          AsnShipmentDetail.new(:order => order,
                                :line_item => line_item,
                                :tracking => tracking,
                                :asn_order_status => shipped_status,
                                :asn_shipping_method_code => asn_shipped,
                                :asn_shipment => asn_shipment,
                                :quantity_shipped => 1) }

        let(:expect_inventory_assigned) { asd_shipped.init_shipment }

        it "should have a shipment" do
          order.shipments.first.should == shipment
        end

        it "should have available shipments" do
          asd_shipped.available_shipment.should == shipment
        end

        it "#init_shipment" do
          expect_inventory_assigned

          asd_shipped.inventory_units.should == [inventory_unit_1]
        end

        it "#assign_shipment" do
          expect_inventory_assigned

          asd_shipped.shipment.should == shipment
        end

        it "#assign_inventory" do
          expect_inventory_assigned

          asd_shipped.inventory_units.should == [inventory_unit_1]
        end

      end

      context "all canceled" do
        let(:canceled) { AsnOrderStatus.find_by_code('26') }
        let(:asn_slash_code) { AsnSlashCode.find_by_code('I1') }

        let(:asd_canceled) { AsnShipmentDetail.new(:order => order,
                                                   :line_item => line_item,
                                                   :asn_order_status => canceled,
                                                   :asn_slash_code => asn_slash_code,
                                                   :asn_shipment => asn_shipment,
                                                   :quantity_canceled => 1) }

        let(:expect_inventory_assigned) { asd_canceled.init_shipment }

        let(:tracking) { nil }

        it "should cancel all the inventory units" do
          expect_inventory_assigned

          shipment.inventory_units.count.should == 0
          asd_canceled.shipment.should == nil
        end

      end
    end


    context "single line / multiple quantity" do

      before :each do
        @order = Cdf::OrderBuilder.create_for_scenario('single order/single line/multiple quantity')
      end

      let(:order) { @order }
      let(:shipment) { order.shipments.first }
      let(:line_item) { order.line_items.first }
      let(:shipping_method) { order.shipping_method }
      let(:inventory_unit_1) { shipment.inventory_units.first }
      let(:inventory_unit_2) { shipment.inventory_units[1] }
      let(:shipment) { order.shipments.first }
      
      
      context "all shipped" do
        let(:asd_shipped) { AsnShipmentDetail.new(:order => order,
                                                  :line_item => line_item,
                                                  :tracking => tracking,
                                                  :asn_order_status => shipped_status,
                                                  :asn_shipping_method_code => asn_shipped,
                                                  :asn_shipment => asn_shipment,
                                                  :quantity_shipped => 2) }

        let(:expect_inventory_assigned) { asd_shipped.init_shipment }
        
        
        it "should have available shipments" do
          asd_shipped.available_shipment.should == shipment
        end

        it "#init_shipment" do
          expect_inventory_assigned
          asd_shipped.inventory_units.should == [inventory_unit_1, inventory_unit_2]
        end

        it "#assign_shipment" do
          expect_inventory_assigned

          asd_shipped.shipment.should == shipment
        end

        it "#assign_inventory" do
          expect_inventory_assigned

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