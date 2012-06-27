require 'spec_helper'
require 'ruby-debug'

describe IngramStockFile do
  it_should_behave_like "an importable file", IngramStockFile, 300, 'dat' do

    let(:outgoing_file) { 'dly_stkv2delta20120504.dat' }
    let(:incoming_file) { 'dly_stkv2delta20120504_out.dat' }

    let(:create_order_1) { %q[Cdf::OrderBuilder.completed_test_order(:ean => %w(9780373200009 978037352805), :order_number => 'R543255800')]}
    let(:create_order_2) { %q[Cdf::OrderBuilder.completed_test_order(:ean => %w(9780373200009 978037352805), :order_number => 'R554266337')]}

    let(:outgoing_contents) do
      %q{%Q[00000768192726000007681927265554233805000000200000000000000000000000000000000000000000000000000000011000000000000000000000000000000000000000000000000000012980001298I37%000129837%IPY       2001061920010619Y99991231N    NYXNN SRT        37%0000211429210IHW 0982  Y R      N21001429210                  ]
      %Q[0000076819752300000768197523555423240X000000300000000000000000000000000000000000000000000000000000000000000300000000000000000000000000000000000000000000012980000491I37%000129837%TPYY      2012062620010731Y99991231N    NNXNN SRT        37%0000211436482IHW 0982  Y R      N21001436482                  ]}
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