Spree::BaseController.class_eval do

  before_filter :init_affiliate
  after_filter :flash_to_headers

  private

  # Adds flash vars to X-Flash[type] headers for xhr requests
  def flash_to_headers
    return unless request.xhr?

    [:error, :notice, :warning].each do |type|
      response.headers["X-Flash[#{type.to_s}]"] = flash[type] if flash[type]
    end

    flash.discard # don't want the flash to appear when you reload page
  end


  def init_affiliate
    params[:affiliate_key] ||= request.session[:affiliate_key]

    Affiliate.init(params[:affiliate_key])
    request.session[:affiliate_key] = Affiliate.current.affiliate_key if Affiliate.has_current?
  end

end
