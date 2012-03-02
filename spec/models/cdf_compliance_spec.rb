require_relative '../spec_helper'

describe "CDF Compliance" do

  before :all do
    @builder = Cdf::OrderBuilder
  end

  context "should handle single order / single line / single quantity" do

    before :each do
      @asn_file = AsnFile.create(:file_name => 'asn-test.txt')


      @order = @builder.completed_test_order({:id => 1,
                                              :name => 'single order/single lines/single quantity',
                                              :line_item_count => 1,
                                              :line_item_qty => 1})

      @line_item = @order.line_items.first

      response = %Q[CR20N2730   000000014.0                                                                                                                                                                                 
OR#{@order.number}                    00000019990000000000000000000000000000000000000000000399000000239800000100   000120111015                                                                               
OD#{@order.number}            C 02367          0373200005037320000500001     00001001ZTESTTRACKCI023670000   SCAC 1              00004990000324#{@line_item.id.to_s.ljust_trim(10)}TESTSSLCI0236700000100000002021#{@line_item.variant.sku.no_dashes.ljust_trim(15)}]

      @asn_file.write_data(response)
      @asn_file.data.should == response
      @asn_file.import

      @order.shipments.reload
    end

    it "should be shipped" do
      @order.shipments.first.state.should == 'shipped'
    end


    it "should import the right number of shipments and shipment details" do
      @asn_file.asn_shipments.count.should == 1
      @asn_file.asn_shipments.first.asn_shipment_details.count.should == 1
    end

    context "asn_shipment" do
      before :each do
        @asn_shipment = @asn_file.asn_shipments.first
      end
      it "should reference order" do
        @asn_shipment.order.should == @order
      end

      it "should have status of shipped" do
        @asn_shipment.asn_order_status.shipped?.should == true
      end
    end

    context "asn_shipment_detail" do
      before :each do
        @asn_shipment_detail = @asn_file.asn_shipments.first.asn_shipment_details.first
      end
      it "should reference order" do
        @asn_shipment_detail.order.should == @order
      end

      it "should have correct quantities" do
        @asn_shipment_detail.quantity_shipped.should == 1
        @asn_shipment_detail.quantity_predicted.should == 1
        @asn_shipment_detail.quantity_slashed.should == 0
      end

      it "should have shipped status" do
        @asn_shipment_detail.asn_order_status.shipped?.should == true
      end

      it "should reference the line item from the order" do
        @asn_shipment_detail.line_item.should_not == nil
      end

      it "should have 1 inventory unit" do
        @asn_shipment_detail.inventory_units.count.should == 1
        @asn_shipment_detail.shipment.inventory_units.count.should == 1
      end

      it "should be shipped" do
        @asn_shipment_detail.shipment.state.should == 'shipped'
        @asn_shipment_detail.inventory_units.first.state.should == 'shipped'
      end

    end
  end

  context "should handle single order / single line / multiple quantity" do

    before :each do
      @asn_file = AsnFile.create(:file_name => 'asn-test.txt')

      @order = @builder.completed_test_order({:id => 1,
                                              :name => 'single order/single lines/single quantity',
                                              :line_item_count => 1,
                                              :line_item_qty => 2})

      @line_item = @order.line_items.first

      response = %Q[CR20N2730   000000014.0                                                                                                                                                                                 
OR#{@order.number.ljust_trim(22)}        00000019990000000000000000000000000000000000000000000399000000239800000100   000120111015                                                                               
OD#{@order.number.ljust_trim(22)}C 02367          0373200005037320000500002     00002001ZTESTTRACKCI023670000   SCAC 1              00004990000324#{@line_item.id.to_s.ljust_trim(10)}TESTSSLCI0236700000100000002021#{@line_item.variant.sku.no_dashes.ljust_trim(15)}]

      @asn_file.write_data(response)
      @asn_file.data.should == response
      @asn_file.import
      @order.shipments.reload
    end

    it "should import the right number of shipments and shipment details" do
      @asn_file.asn_shipments.count.should == 1
      @asn_file.asn_shipments.first.asn_shipment_details.count.should == 1
    end

    context "asn_shipment" do
      before :each do
        @asn_shipment = @asn_file.asn_shipments.first
      end
      it "should reference order" do
        @asn_shipment.order.should == @order
      end

      it "should have status of shipped" do
        @asn_shipment.asn_order_status.shipped?.should == true
      end
    end

    context "asn_shipment_detail" do
      before :each do
        @asn_shipment_detail = @asn_file.asn_shipments.first.asn_shipment_details.first
      end
      it "should reference order" do
        @asn_shipment_detail.order.should == @order
      end

      it "should have correct quantities" do
        @asn_shipment_detail.quantity_shipped.should == 2
        @asn_shipment_detail.quantity_predicted.should == 2
        @asn_shipment_detail.quantity_slashed.should == 0
      end

      it "should have shipped status" do
        @asn_shipment_detail.asn_order_status.shipped?.should == true
      end

      it "should reference the line item from the order" do
        @asn_shipment_detail.line_item.should_not == nil
      end

      it "should have 2 inventory units" do
        @asn_shipment_detail.inventory_units.count.should == 2
        @asn_shipment_detail.shipment.inventory_units.count.should == 2
      end

      it "should be shipped" do
        @asn_shipment_detail.shipment.state.should == 'shipped'
        @asn_shipment_detail.inventory_units.first.state.should == 'shipped'
      end

      it "should have tracking" do
        @asn_shipment_detail.shipment.reload.tracking.should == @asn_shipment_detail.tracking
      end

    end
  end

  context "should handle multiple boxes from single order" do

    before :each do
      @order = @builder.completed_test_order({:id => 1,
                                              :name => 'single order/single lines/single quantity',
                                              :line_item_count => 1,
                                              :line_item_qty => 30,
                                              :ean_type => :multiple_boxes})

      @line_item = @order.line_items.first

      response = %Q[CR20N2730   000000014.0                                                                                                                                                                                 
OR#{@order.number.ljust_trim(22)}        00000599700000000000000000000000000000000000000000003270000006324000003000   000320111021                                                                               
OD#{@order.number.ljust_trim(22)}C 02415          0373200005037320000500010     00010001ZTESTTRACKCI024150001   SCAC 1              00004990000289#{@line_item.id.to_s.ljust_trim(10)}TESTSSLCI0241500000200000020021#{@line_item.variant.sku.no_dashes.ljust_trim(15)}      
OD#{@order.number.ljust_trim(22)}C 02415          0373200005037320000500010     00010001ZTESTTRACKCI024150002   SCAC 1              00004990000289#{@line_item.id.to_s.ljust_trim(10)}TESTSSLCI0241500000300000020021#{@line_item.variant.sku.no_dashes.ljust_trim(15)}      
OD#{@order.number.ljust_trim(22)}C 02415          0373200005037320000500010     00010001ZTESTTRACKCI024150003   SCAC 1              00004990000289#{@line_item.id.to_s.ljust_trim(10)}TESTSSLCI0241500000400000020021#{@line_item.variant.sku.no_dashes.ljust_trim(15)}]

      @asn_file = AsnFile.create(:file_name => 'asn-test-multibox.txt')
      @asn_file.write_data(response)
      @asn_file.data.should == response

      @ship_cost_before = @order.ship_total

      @asn_file.import
      @order.shipments.reload

      @ship_cost_before.should == @order.ship_total
    end

    it "should import the right number of shipments and shipment details" do
      @asn_file.asn_shipments.count.should == 1
      @asn_file.asn_shipments.first.asn_shipment_details.count.should == 3
    end

    context "asn_shipment" do
      before :each do
        @asn_shipment = @asn_file.asn_shipments.first
      end

      it "should reference order" do
        @asn_shipment.order.should == @order
      end

      it "should have status of shipped" do
        @asn_shipment.asn_order_status.shipped?.should == true
      end
    end

    context "asn_shipment_detail" do
      before :each do
        @asn_shipment_details = @asn_file.asn_shipments.first.asn_shipment_details
      end

      it "should have the correct shipping cost" do
        @order.shipments.each_with_index do |s, i|
          s.inventory_units.count.should == 10
          if i == 0
            s.cost.to_s('F').should == '12.9'
          else
            s.cost.to_s('F').should == '9.9'
          end
        end
      end

      it "should reference order" do
        @asn_shipment_details.each { |s| s.order.should == @order }
      end

      it "should have the correct number of details" do
        @asn_shipment_details.size.should == 3
      end

      it "should have correct quantities" do
        @asn_shipment_details.each do |s|
          s.quantity_shipped.should == 10
          s.quantity_predicted.should == 10
          s.quantity_slashed.should == 0
          s.inventory_units.count.should == 10
        end
      end

      it "should have shipped status" do
        @asn_shipment_details.each do |s|
          s.asn_order_status.shipped?.should == true
        end
      end

      it "should reference the line item from the order" do
        @asn_shipment_details.each do |s|
          s.line_item.should_not == nil
        end
      end


      it "should be shipped" do
        @asn_shipment_details.each do |s|
          s.shipment.state.should == 'shipped'
          s.inventory_units.first.state.should == 'shipped'
          s.shipment.tracking.should_not == nil
        end

      end
    end


  end

  context "should handle short ship/slash a single line from a multiple line order" do

    before :each do
      @order = @builder.completed_test_order({:id => 1,
                                              :name => 'short ship/slash a single line from a multiple line order',
                                              :ean_type => [:slash_by_1, :in_stock]})

      @line_item = @order.line_items.first

      response = %Q[CR20N2730   000000014.0                                                                                                                                                                                 
OR#{@order.number.ljust_trim(22)}        00000019990000000000000000000000000000000000000000000498000000249700000000   000120111025                                                                               
OD#{@order.number.ljust_trim(22)}C 02415          0373200005037320000500001     00001001ZTESTTRACKCI024550000   SCAC 1              00004990000324#{@line_item.id.to_s.ljust_trim(10)}TESTSSLCI0245500000100000002021#{@line_item.variant.sku.no_dashes.ljust_trim(15)}]

      @asn_file = AsnFile.create(:file_name => 'asn-test-multibox.txt')
      @asn_file.write_data(response)
      @asn_file.data.should == response

      @ship_cost_before = @order.ship_total

      @asn_file.import

      @order.shipments.reload

      @ship_cost_before.should == @order.ship_total

      #@order.shipments.each { |s| puts "Shipment: #{s.state}" }
    end

    context "import first response" do

      it "should import the right number of shipments and shipment details" do
        @asn_file.asn_shipments.count.should == 1
        @asn_file.asn_shipments.first.asn_shipment_details.count.should == 1
        @order.shipments.count.should == 2
      end

      context "asn_shipment" do
        before :each do
          @asn_shipment = @asn_file.asn_shipments.first
        end
        it "should reference order" do
          @asn_shipment.order.should == @order
        end

        it "should have status of shipped" do
          @asn_shipment.asn_order_status.shipped?.should == true
        end
      end

      context "asn_shipment_detail" do
        before :each do
          @asn_shipment_details = @asn_file.asn_shipments.first.asn_shipment_details
          @asn_shipment_detail = @asn_shipment_details.first
        end

        it "should have the correct shipping cost" do
          @order.shipments.each_with_index do |s, i|
            s.inventory_units.count.should == 1
            if i == 0
              s.cost.should == BigDecimal.new('3.99')
            else
              s.cost.should == BigDecimal.new('0.99')
            end
          end
        end

        it "should have the correct number of details" do
          @asn_shipment_details.size.should == 1
        end

        it "should reference order" do
          @asn_shipment_detail.order == @order
        end

        it "should have correct quantities" do
          @asn_shipment_detail.quantity_shipped.should == 1
          @asn_shipment_detail.quantity_predicted.should == 1
          @asn_shipment_detail.quantity_slashed.should == 0
          @asn_shipment_detail.inventory_units.count.should == 1
        end

        it "should have shipped status" do
          @asn_shipment_detail.asn_order_status.shipped?.should == true
        end

        it "should reference the line item from the order" do
          @asn_shipment_detail.line_item.should == @line_item
        end

        it "should be shipped" do
          @order.shipments.all.each { |s| s.reload }
          @asn_shipment_detail.shipment.reload
          @asn_shipment_detail.shipment.state.should == 'shipped'
          @asn_shipment_detail.inventory_units.each { |u| u.state.should == 'shipped' }
          @asn_shipment_detail.shipment.tracking.should == @asn_shipment_detail.tracking
        end
      end
    end


    context "import second / slashed response" do

      before :each do
        @line_item = @order.line_items[1]

        response = %Q[CR20N2730   000000014.0                                                                                                                                                                                 
OR#{@order.number.ljust_trim(22)}        280000000000000000000000000000000000000000000000000000000000000000     000   000120111025                                                                               
OD#{@order.number.ljust_trim(22)}C 02455          039484836503948483650000100001     28                              10             0001999      0#{@line_item.id.to_s.ljust_trim(10)}                            0S1#{@line_item.variant.sku.no_dashes.ljust_trim(15)}]

        @asn_file = AsnFile.create(:file_name => 'asn-test-multibox-2.txt')
        @asn_file.write_data(response)
        @asn_file.data.should == response
        @ship_cost_before = @order.ship_total

        @asn_file.import
        @order.shipments.reload

      end

      it "should import the right number of shipments and shipment details" do
        @asn_file.asn_shipments.count.should == 1
        @asn_file.asn_shipments.first.asn_shipment_details.count.should == 1
        @order.shipments.count.should == 1
      end

      context "asn_shipment" do
        before :each do
          @asn_shipment = @asn_file.asn_shipments.first
        end
        it "should reference order" do
          @asn_shipment.order.should == @order
        end

        it "should have status of shipped" do
          @asn_shipment.asn_order_status.partial_shipment?.should == true
        end
      end

      context "asn_shipment_detail" do
        before :each do
          @asn_shipment_details = @asn_file.asn_shipments.first.asn_shipment_details
          @asn_shipment_detail = @asn_shipment_details.first
        end

        it "should import 1 asn_shipment_detail" do
          @asn_shipment_details.count.should == 1
        end

        it "should have the correct shipping cost" do
          @asn_shipment_detail.shipment.should == nil
        end

        it "should reference order" do
          @asn_shipment_detail.order.should == @order
        end

        it "should have correct quantities" do
          @asn_shipment_detail.quantity_shipped.should == 0
          @asn_shipment_detail.quantity_predicted.should == 1
          @asn_shipment_detail.quantity_slashed.should == 1
          @asn_shipment_detail.inventory_units.count.should == 0
        end

        it "should have shipped status" do
          @asn_shipment_detail.asn_order_status.shipped?.should == false
          @asn_shipment_detail.asn_order_status.partial_shipment?.should == true
        end

        it "should reference the line item from the order" do
          @asn_shipment_detail.line_item.should == @line_item
        end

      end
    end


  end
end