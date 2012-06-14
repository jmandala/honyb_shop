Spree::BaseController.class_eval do

  #noinspection RubyResolve
  before_filter :init_affiliate

  private

  def init_affiliate
    params[:honyb_id] ||= request.session[:honyb_id]
    
    Affiliate.init(params[:honyb_id])
    request.session[:honyb_id] = Affiliate.current.honyb_id if Affiliate.has_current?
  end

end
