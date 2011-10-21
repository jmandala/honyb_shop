require_relative '../spec_helper'

describe "CDF Compliance" do

  before :each do
    @builder = Cdf::OrderBuilder
    AsnFile.all.each &:destroy
  end

  context "should handle single order / single line / single quantity" do

    before :each do
      @order = @builder.completed_test_order({:id => 1,
                                              :name => 'single order/single lines/single quantity',
                                              :line_item_count => 1,
                                              :line_item_qty => 1})

      response = "" "
CR20N2730   000000014.0                                                                                                                                                                                 
OR#{@order.number}                    00000019990000000000000000000000000000000000000000000399000000239800000100   000120111015                                                                               
OD#{@order.number}            C 02367          0373200005037320000500001     00001001ZTESTTRACKCI023670000   SCAC 1              000049900003244         TESTSSLCI02367000001000000020219780373200009    
" ""

      @asn_file = AsnFile.create(:file_name => 'asn-test.txt')
      @asn_file.write_data(response)
      @asn_file.data.should == response

    end


    it "should import the asn file" do
      @asn_file.import

      @order.asn_files.count.should == 1
      @asn_file.asn_shipments.first.order.should == @order
    end


  end

end