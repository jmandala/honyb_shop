require_relative "../spec_helper"

describe 'order_decorator' do

  let(:order) { Order.new }

  context "with regard to constants" do
    it "should have an ORDER_NAME" do
      Order::ORDER_NAME.should == 'Order Name'
    end

    it "should define TYPES" do
      Order::TYPES.should == [:live, :test]
    end

    it "should define SPLIT_SHIPMENT_TYPE" do
      Order::SPLIT_SHIPMENT_TYPE.should == {:multi_shipment => 'EL', :release_when_full => 'RF', :dual_shipment => 'LS'}
    end
  end


  it "should have no tax_rate" do
    order.tax_rate.should == nil
  end

  context "with regard to associations" do

    it "should have an array of children orders" do
      order.children.should == []
    end

    it "should have a nil parent" do
      order.parent.should == nil
    end

    it "should have a po_file" do
      order.po_file.should == nil
    end

    it "should have a dc_code" do
      order.dc_code.should == nil
    end

    it "should have poa_order_headers" do
      order.poa_order_headers.should == []
    end

    it "should have poa_files" do
      order.poa_files.should == []
    end

    it "should have asn_shipments" do
      order.asn_shipments.should == []
    end

    it "should have asn_files" do
      order.asn_files.should == []
    end

    it "should have cdf_invoice_detail_totals" do
      order.cdf_invoice_detail_totals.should == []
    end

    it "should have cdf_invoice_freight_and_fees" do
      order.cdf_invoice_freight_and_fees.should == []
    end

    it "should have cdf_invoice_headers" do
      order.cdf_invoice_headers.should == []
    end
    
    it "should have comments" do
      order.comments.should == []
    end
  end


  context "when handling gift orders" do
    it "should have no gift wrap fee" do
      order.gift_wrap_fee.should == 0
    end

    it "should not be a gift" do
      order.is_gift?.should == false
    end

    it "should have no gift message" do
      order.gift_message.should == ''
    end
  end


  context "when handling test orders" do
    it "should not be a test" do
      order.test?.should == false
    end

    it "should be a live order" do
      order.live?.should == true
    end

    it "should convert a live order to a test order" do
      order.test?.should == false
      order.live?.should == true
      order.to_test
      order.test?.should == true
      order.live?.should == false
    end
    
    it "should create a test order" do
      test_order = Order.create_test_order
      test_order.live?.should == false
      test_order.test?.should == true
      test_order.email.should == User::COMPLIANCE_EMAIL
    end
  end


  context "when handling po files" do
    it "should not need a po" do
      order.needs_po?.should == false
    end

    it "should not be ready for a po" do
      order.ready_for_po?.should == false
    end

    it "should return a reasonable po requirement" do
      order.po_requirements.should == ['not complete!', 'shipment state is \'\', should be \'ready\'.']
    end

    it "should not have a po" do
      order.has_po?.should == false
    end
  end
  
  context "when working with order_name" do
    it "should set an order_name" do
      order.order_name.should == ''
      order.order_name = 'test order'
      order.order_name.should == 'test order'
    end
  end
  
  

end


