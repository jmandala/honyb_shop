class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :normal_cookies_for_ie_in_iframes!
  
  helper :all

end
