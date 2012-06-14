Spree::BaseController.class_eval do

  #noinspection RubyResolve
  before_filter :init_affiliate

  private

  def init_affiliate
    params[:affiliate_key] ||= request.session[:affiliate_key]
    
    Affiliate.init(params[:affiliate_key])
    request.session[:affiliate_key] = Affiliate.current.affiliate_key if Affiliate.has_current?
  end

end
