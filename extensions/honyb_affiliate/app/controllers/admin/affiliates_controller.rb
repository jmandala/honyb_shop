class Admin::AffiliatesController < Admin::ResourceController
  
  def index
    respond_with(@collection) do |format|
      format.html
      format.json { render :json => json_data }
    end
  end
  
  
  protected

  def collection
    return @collection if @collection.present?
    unless request.xhr?
      @search = Affiliate.metasearch(params[:search])
      @collection = @search.relation.page(params[:page]).per(Spree::Config[:admin_products_per_page])
    else
      #disabling proper nested include here due to rails 3.1 bug
      #@collection = User.includes(:bill_address => [:state, :country], :ship_address => [:state, :country]).
      @collection = Affiliate.all
    end
  end

end