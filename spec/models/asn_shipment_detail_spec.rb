describe AsnShipmentDetail do

  let(:shipped_status) { mock_model(AsnOrderStatus, :shipped? => true) }
  let(:asd_shipped) { AsnShipmentDetail.new(:asn_order_status => shipped_status) }
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
      asd_shipped.shipped?.should == true
    end
  end

  it "#missing_shipment" do
    3.times { AsnShipmentDetail.create }
    AsnShipmentDetail.missing_shipment.count.should == 3
  end

  context "initializes shipment" do

    let(:variant_1) { mock_model(Variant, :sku => '999', :id => 1) }
    let(:line_item_1) { mock_model(LineItem, :variant => variant_1, :quantity => 1) }
    let(:order) { mock_model(Order, :id => 1, :completed? => true, :canceled? => false, :line_items => [line_item_1]) }
    let(:inventory_unit_1) { InventoryUnit.new(:variant => variant_1, :order => order) }
    let(:shipping_method) { mock_model(ShippingMethod, :id => 1) }
    let(:shipment) { mock_model(Shipment,
                                :tracking => '',
                                :inventory_units => [inventory_unit_1],
                                :unassign_sold_inventory => :self,
                                :ship => true,
                                :ship! => true) }

    let(:asn_shipped) { mock_model(AsnShippingMethodCode, :shipping_method => shipping_method, :code => '00', :description => 'Shipped') }
    let(:asn_slashed) { mock_model(AsnShippingMethodCode, :code => 'S1', :description => 'DC Slash (warehouse)') }

    context "has a tracking number" do

      let(:tracking) { '1234567' }


      context "single line / single quantity" do


        let(:asd_shipped) { AsnShipmentDetail.new(:order => order,
                                                  :line_item => line_item_1,
                                                  :tracking_number => tracking,
                                                  :asn_order_status => shipped_status,
                                                  :asn_shipping_method_code => asn_shipped,
                                                  :quantity_shipped => 1) }

        let(:available_shipment_sql) { "order_id = #{order.id} AND shipping_method_id = #{shipping_method.id} AND tracking = '#{tracking}'" }

        before :each do
          now = Time.now
          Time.stub(:now) { now }
          order.stub(:inventory_units) { mock(Object, :sold => [inventory_unit_1]) }
        end

        it "should have a tracking number" do
          asd = asd_shipped
          asd.tracking_number.should_not == nil
        end

        it "should have available shipments" do
          Shipment.should_receive(:where).with(available_shipment_sql) { [shipment] }
          asd_shipped.available_shipments(tracking).should == [shipment]
        end

        context "all shipped" do

          context "single AsnShipmentDetail to a single Shipment, with a single LineItem and a quantity of 1" do
            let(:expect_available_shipments) { Shipment.should_receive(:where).with(available_shipment_sql) { [shipment] } }

            before :each do
              #expect_available_shipments
            end

            it "#init_shipment" do
              expect_available_shipments
              shipment.should_receive(:save!)
              shipment.should_receive(:tracking=).with(tracking)

              asd_shipped.init_shipment(tracking).should == shipment
            end

            it "#assign_shipment" do
              shipment.should_receive(:save!)
              shipment.should_receive(:tracking=).with(tracking)

              asd_shipped.assign_shipment(shipment, tracking)
              asd_shipped.shipment.should == shipment
            end

            it "#assign_inventory" do
              asd_shipped.assign_inventory(shipment)
              asd_shipped.inventory_units.should == [inventory_unit_1]
            end

          end


        end
        context "partial shipped"
        context "none shipped"

      end
=begin
      context "multi-line / single quantity" do
        context "one order, one shipment, two AsnShipmentDetails" do
          let(:asd_2) { AsnShipmentDetail.new(:order => order, :tracking_number => tracking_2, :asn_order_status => shipped, :asn_shipping_method_code => asn_shipping_method_code, :quantity_shipped => 2) }
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

      context "single line / multiple quantity" do

      end
      context "multi-line / multiple quantity"

    end

    context "has no tracking number"


    context "all items shipped" do


    end

  end
end