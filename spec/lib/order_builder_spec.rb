require_relative '../spec_helper'

describe 'OrderBuilder' do
  it "should have a list of scenarios" do
    Cdf::OrderBuilder::SCENARIOS.should_not == nil
  end
end