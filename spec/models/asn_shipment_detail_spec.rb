describe AsnShipmentDetail do

  let(:asd) { AsnShipmentDetail.new }

  after :each do
    AsnShipmentDetail.all.each &:destroy
  end

  context "default associations" do
    it "should have no line item" do
      asd.line_item.should == nil
    end

    it "should have no order" do
      asd.order.should == nil
    end

    it "should have no inventory units" do
      asd.inventory_units.empty?.should == true
    end

    it "should have no asn_file" do
      asd.asn_file.should == nil
    end

    it "should have no asn_shipment" do
      asd.asn_shipment.should == nil
    end

    it "should have no product" do
      asd.product.should == nil
    end

    it "should have no variant" do
      asd.variant.should == nil
    end

    it "should not be shipped" do
      asd.shipped?.should == false
    end

    it "should be shipped if status is shipped" do
      asd.stub :asn_order_status => mock_model(AsnOrderStatus, :shipped? => true)
      asd.shipped?.should == true
    end
  end

  context "initializes shipment" do

    let(:tracking) { '1234567' }
    let(:shipped) { mock_model(AsnOrderStatus, :shipped? => true) }
    let(:line_item) { mock_model(LineItem) }
    let(:order) { mock_model(Order, :id => 1, :completed? => true, :canceled? => false, :line_items => [line_item]) }
    let(:shipping_method) { mock_model(ShippingMethod, :id => 1) }
    let(:inventory_unit) { mock_model(InventoryUnit) }
    let(:asn_shipping_method_code) { mock_model(AsnShippingMethodCode, :shipping_method => shipping_method, :code => '00', :description => 'Shipped') }
    let(:shipment) { mock_model(Shipment, :tracking => tracking, :ship => true, :ship! => true) }
    let(:asd) { AsnShipmentDetail.new(:order => order, :tracking_number => tracking, :asn_order_status => shipped, :asn_shipping_method_code => asn_shipping_method_code) }

    before :each do
      3.times { AsnShipmentDetail.create }
      Shipment.stub(:where).with("order_id = 1\n      AND shipping_method_id = 1\n      AND (shipped_at IS NULL OR tracking = '1234567'") { [shipment] }
      shipment.stub(:tracking=).with(tracking)
    end

    it "should find AsnShipmentDetail's missing shipments" do
      AsnShipmentDetail.missing_shipment.count.should == 3
    end


    it "should have available shipments" do
      asd.available_shipments.size.should == 1
      asd.available_shipments.should == [shipment]
    end

    it "should assign a single asn to a single shipment" do
      asd.init_shipment(tracking).should == shipment
      asd.shipment.should_not == nil
      asd.shipment.tracking.should == tracking
    end

    context "one order, one shipment, two AsnShipmentDetails" do
      let(:asd_2) { AsnShipmentDetail.new(:order => order, :tracking_number => tracking_2, :asn_order_status => shipped, :asn_shipping_method_code => asn_shipping_method_code) }
      let(:tracking_2) { tracking + "123" }      
      let(:shipment_2) { mock_model(Shipment, :tracking => tracking_2, :ship => true, :ship! => true) }


      before :each do
        Shipment.stub(:where).with("order_id = #{order.id}\n      AND shipping_method_id = 1\n      AND (shipped_at IS NULL OR tracking = '#{tracking_2}'") { [shipment, shipment_2] }
        shipment.stub(:tracking=).with(tracking)
        shipment_2.stub(:tracking=).with(tracking_2)
      end


      it "should assign two AsnShipmentDetails to the same shipment when they have the same tracking" do
        asd.init_shipment(tracking).should == shipment
        asd_2.init_shipment(tracking_2).should == shipment
      end
    end

  end
end