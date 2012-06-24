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

    report_def = [
        {'number' => lambda{ |o, li| o.number }}
    ]

    @table = Ruport::Data::Table(cols_from_report_def(report_def))
    #completed_at 
    
    #            affiliate_key 
    #            email 
    #            line_item_name 
    #            line_item_sku 
    #            line_item_qty 
    #            line_item_price
    #            bill_firstname
    #            bill_lastname
    #            bill_address_line_1
    #            bill_address_line_2
    #            bill_address_city
    #            bill_address_state
    #            bill_address_zip
    #            bill_address_country
    #
    @orders.each do |o|
      o.line_items.each do |li|
        @table << col_vals_from_report_def(report_def, o, li)
        #row = {'number' => o.number, 'affiliate_key' => o.affiliate_key}
        #row['email'] = o.email
        #row['completed_at'] = o.completed_at
        #row['line_item_name'] = li.product.name
        #row['line_item_sku'] = li.product.sku
        #row['line_item_qty'] = li.quantity
        #row['line_item_price'] = li.price
        #row['bill_address_line_1'] = o.bill_address.address1
        #row['bill_address_line_2'] = o.bill_address.address2
      end
    end

    respond_with
  end

  def cols_from_report_def(report_def)
    cols = []
    report_def.each do |column_def|
      column_def.keys.each {|k| cols << k}
    end
    cols
  end
  
  def col_vals_from_report_def(report_def, order, line_item)
    results = {}
    report_def.each do |column_def|
      column_def.each do |k, v|
        results[k] = v.yield(order, line_item)
      end
    end
    results
  end

end