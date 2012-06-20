Admin::ReportsController.class_eval do

  before_filter :add_own

  def add_own
    available_reports = Admin::ReportsController::AVAILABLE_REPORTS
    return if available_reports.has_key?(:sales_details)
    available_reports[:sales_detail] = {:name => I18n.t(:sales_detail), :description => I18n.t(:sales_detail_description)}
  end

  def sales_detail

    params[:search] = {} unless params[:search]

    if params[:search][:created_at_greater_than].blank?
      params[:search][:created_at_greater_than] = Time.zone.now.beginning_of_month
    else
      params[:search][:created_at_greater_than] = Time.zone.parse(params[:search][:created_at_greater_than]).beginning_of_day rescue Time.zone.now.beginning_of_month
    end

    if params[:search] && !params[:search][:created_at_less_than].blank?
      params[:search][:created_at_less_than] =
          Time.zone.parse(params[:search][:created_at_less_than]).end_of_day rescue ""
    end

    if params[:search].delete(:completed_at_is_not_null) == "1"
      params[:search][:completed_at_is_not_null] = true
    else
      params[:search][:completed_at_is_not_null] = false
    end

    params[:search][:meta_sort] ||= "created_at.desc"

    @search = Order.metasearch(params[:search])
    @orders = @search

    respond_with
  end


end