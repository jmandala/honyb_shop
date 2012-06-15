require 'spec_helper'

describe "the affiliate_key filter", :type => :request do
  let(:affiliate_key) { 'the-affiliate-id' }

  before do
    Affiliate.current = nil
    Affiliate.create(:affiliate_key => affiliate_key )
  end

  it "captures the affiliate_key and appends it to all urls" do
    visit "/h-#{affiliate_key}"
    puts page.html
    page.should have_selector("body.normal.#{affiliate_key}")
  end
  
  it "captures the embed AND affiliate_key and appends it to all urls" do
    visit "/embed/h-#{affiliate_key}"
    puts page.html
    page.should have_selector("body.embed.#{affiliate_key}")
  end
  
end
