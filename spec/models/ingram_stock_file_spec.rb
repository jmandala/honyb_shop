require 'spec_helper'

describe IngramStockFile do
  it_should_behave_like "an importable file", IngramStockFile, 300, 'zip' do

    let(:outgoing_file) { 'stockv2delta120702a@ingram.zip' }
    let(:incoming_file) { 'stockv2delta120702a@ingram.zip' }

    let(:create_order_1) { %q[Cdf::OrderBuilder.completed_test_order(:ean => %w(9780373200009 978037352805), :order_number => 'R543255800')]}
    let(:create_order_2) { %q[Cdf::OrderBuilder.completed_test_order(:ean => %w(9780373200009 978037352805), :order_number => 'R554266337')]}

    let(:binary_file_name) { 'testingram.zip' }

    let(:outgoing_contents) do
      %q[%Q[097800714182180063978538298000714182100000012000000000000000000000000000000000000000000000000000000120000012000000000000000000000000000000000000000000000349500034957REG0003495REGIPYY      2003062400010101Y99991231N    NYR   REG        35%0001601991602MGWH0533    R      N21001991602#{"                  "}
09780140177398              01401773960000153000091900000000000405000000000000000000000000000000003850000000000096000000000000000000000000000000000000000100000010007REG0001000REGIPYYYY    1993090100010101Y99991231N    NYQ   REG        REG0000170053002PNGN4164    R      N21000053002#{"                  "}
09780230603271              0230603270000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000095000009500M 5%0009500 5%IPY  Y    2008080100010101Y99991231N    YYR   SRT         5%0000943355321PRAVS103    R      N22003355321#{"                  "}
]]
   end

    let(:validations) do
      []
    end


    let(:test_contents) do
      outgoing_contents
    end

    before :each do
      FactoryGirl.create(:chambersburg)
    end

  end
end