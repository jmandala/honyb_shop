require_relative '../spec_helper'

describe "CDF Compliance" do

  before :each do
    @builder = Cdf::OrderBuilder


    @asn_file = AsnFile.create(:file_name => 'asn-test.txt')

  end

  context "should handle single order / single line / single quantity" do

    before :each do
      AsnFile.all.each &:destroy

      
      @order = @builder.completed_test_order({:id => 1,
                                              :name => 'single order/single lines/single quantity',
                                              :line_item_count => 1,
                                              :line_item_qty => 1})

      @line_item = @order.line_items.first
      
      response = """
CR20N2730   000000014.0                                                                                                                                                                                 
OR#{@order.number}                    00000019990000000000000000000000000000000000000000000399000000239800000100   000120111015                                                                               
OD#{@order.number}            C 02367          0373200005037320000500001     00001001ZTESTTRACKCI023670000   SCAC 1              00004990000324#{@line_item.id.to_s.ljust_trim(10)}TESTSSLCI0236700000100000002021#{@line_item.variant.sku.no_dashes.ljust_trim(15)}       
"""

      @asn_file.write_data(response)
      @asn_file.data.should == response
      @asn_file.import
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
      end
      
      it "should be shipped" do
        @asn_shipment_detail.shipment.state.should == 'shipped'
        @asn_shipment_detail.inventory_units.first.state.should == 'shipped'
      end

    end


  end

end