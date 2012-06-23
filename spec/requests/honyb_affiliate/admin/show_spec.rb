require 'spec_helper'

describe "admin/users/show" do
  let(:affiliate_key) { 'the-affiliate-id' }

  before do
    Affiliate.current = nil
    Affiliate.create(:affiliate_key => affiliate_key)
  end

  it "Log In", :js => true do
    pending "doesn't work!'"
    visit '/account/login'

    fill_in "login_email", :with => "spree@example.com"
    fill_in "login_password", :with => "spree1123"

    click_button "Log In"
    find "#embed"
  end

end
