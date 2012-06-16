require 'spec_helper'

describe "the affiliate_key filter" do

  before do
    @affiliate_key = 'affiliate-key-value'
    Affiliate.current = nil
    Affiliate.create(:affiliate_key => @affiliate_key )
  end
  
  it "captures the affiliate_key and appends it to all urls" do
    pending "kills subsequent tests!"
    visit "/h-#@affiliate_key"
    page.should have_selector("body.normal.#@affiliate_key")
  end
  

  it "captures the embed AND affiliate_key and appends it to all urls" do
    pending "kills subsequent tests!"
    
    visit "/embed/h-#@affiliate_key"
    page.should have_selector("body.embed.#@affiliate_key")
  end
  
end
