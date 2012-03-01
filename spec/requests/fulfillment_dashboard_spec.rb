require 'spec_helper'

RSpec.configure do |config|
  config.filter_run_excluding :broken
end

describe "admin fulfillment dashboard", :broken do

  let(:email) { 'spree@example.com' }
  let(:password) { 'spree123' }
  let(:user) { User.find_by_email email }

  before :all do
    unless user.valid_password?(password)
      user.password = password
      user.save!
    end
  end

  it "should have a valid password" do
    user.valid_password?(password).should == true
  end

  it "should return an error message when invalid log is attempted" do
    visit '/login'
    click_button 'Log In'
    find('.flash.errors').text.should == I18n.t('devise.failure.invalid')
  end

  it "should log in successfully" do
    visit '/login'
    fill_in 'login_email', :with => email
    fill_in 'login_password', :with => password
    click_button 'Log In'

    find('.flash.notice').text.should == I18n.t(:logged_in_succesfully)
  end

  it "should recognize the decorated methods" do
    Order.respond_to?(:create_test_order).should == true
  end

  context "login with valid credentials" do

    before :each do
      visit '/login'
      fill_in 'login_email', :with => 'spree@example.com'
      fill_in 'login_password', :with => 'spree123'
      click_button 'Log In'
    end

    it 'includes the cdf admin links' do
      visit '/admin/fulfillment/dashboard'

      save_and_open_page

      within '#sub_nav' do
        find('li.selected').text.should == I18n.t(:dashboard)
      end

    end
  end
end

