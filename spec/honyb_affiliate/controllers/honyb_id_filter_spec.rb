require 'spec_helper'

describe "the honyb_id filter", :type => :request do
  let(:honyb_id) { 'the-affiliate-id' }

  before do
    Affiliate.current = nil
    Affiliate.create(:honyb_id => honyb_id )
  end

  it "captures the honyb_id and appends it to all urls" do
    visit "/h-#{honyb_id}"
    puts page.html
    page.should have_selector("body.normal.#{honyb_id}")
  end
  
  it "captures the embed AND honyb_id and appends it to all urls" do
    visit "/embed/h-#{honyb_id}"
    puts page.html
    page.should have_selector("body.embed.#{honyb_id}")
  end
  
end
