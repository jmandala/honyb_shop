Admin::ProductsController.class_eval do
  before_filter :set_product_types, :only => [:edit]

  def set_product_types
    arrays_hash = Product.setup_dropdowns
    @types_array = arrays_hash[:types]
    @available_array = arrays_hash[:available]
    @status_array = arrays_hash[:status]
  end

  def collection
    return @collection if @collection.present?

    unless request.xhr?
      params[:search] ||= {}
      # Note: the MetaSearch scopes are on/off switches, so we need to select "not_deleted" explicitly if the switch is off
      if params[:search][:deleted_at_is_null].nil?
        params[:search][:deleted_at_is_null] = "1"
      end

      params[:search][:meta_sort] ||= "name.asc"
      @search = super.metasearch(params[:search])

      @collection = @search.includes({:variants => [:images, :option_values]}).page(params[:page]).per(Spree::Config[:admin_products_per_page])
    else
      includes = [{:variants => [:images,  {:option_values => :option_type}]}, :master, :images]

      @collection = super.where(["name #{LIKE} ?", "%#{params[:q]}%"])
      @collection = @collection.includes(includes).limit(params[:limit] || 10)

      tmp = super.where(["variants.sku #{LIKE} ?", "%#{params[:q]}%"])
      tmp = tmp.includes(:variants_including_master).limit(params[:limit] || 10)
      @collection.concat(tmp)

      @collection.uniq
    end

  end

  def get_biblio_info
    if @product.get_biblio_data!
      flash[:notice] = "Successfully retrieved Bibliographical Info for this item"
    else
      flash[:error] = "Unable to retrieve Bibliographical Info for this item"
    end
    redirect_to biblio_info_admin_product_url(@product)
  end
end