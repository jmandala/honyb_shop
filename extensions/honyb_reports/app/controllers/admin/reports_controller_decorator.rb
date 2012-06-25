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
        {'number' => lambda { |o, li| o.number }},
        {'completed at' => lambda { |o, li| o.completed_at }},
        {'affiliate key' => lambda { |o, li| o.affiliate_key }},
        {'shipment state' => lambda { |o, li| o.shipment_state }},
        {'payment state' => lambda { |o, li| o.payment_state }},
        {'order total' => lambda { |o, li| o.total }},
        {'payment total' => lambda { |o, li| o.payment_total }},
        {'email' => lambda { |o, li| o.email }},
        {'bill-to first name' => lambda { |o, li| o.bill_address.firstname }},
        {'bill-to last name' => lambda { |o, li| o.bill_address.lastname }},
        {'bill-to address 1' => lambda { |o, li| o.bill_address.address1 }},
        {'bill-to address 2' => lambda { |o, li| o.bill_address.address2 }},
        {'bill-to city' => lambda { |o, li| o.bill_address.city }},
        {'bill-to zipcode' => lambda { |o, li| o.bill_address.zipcode }},
        {'bill-to country' => lambda { |o, li| o.bill_address.country.iso3 }},
        {'ship-to first name' => lambda { |o, li| o.ship_address.firstname }},
        {'ship-to last name' => lambda { |o, li| o.ship_address.lastname }},
        {'ship-to address 1' => lambda { |o, li| o.ship_address.address1 }},
        {'ship-to address 2' => lambda { |o, li| o.ship_address.address2 }},
        {'ship-to city' => lambda { |o, li| o.ship_address.city }},
        {'ship-to zipcode' => lambda { |o, li| o.ship_address.zipcode }},
        {'ship-to country' => lambda { |o, li| o.ship_address.country.iso3 }},
        {'line item name' => lambda { |o, li| li.product.name }},
        {'line item sku' => lambda { |o, li| li.product.sku }},
        {'line item qty' => lambda { |o, li| li.quantity }},
        {'line item price' => lambda { |o, li| li.price }},
    ]

    @table = Ruport::Data::Table(cols_from_report_def(report_def))

    @orders.each do |o|
      o.line_items.each do |li|
        @table << col_vals_from_report_def(report_def, o, li)
      end
    end

    respond_with
  end

  # Returns an array of column names from the report_def
  # Report_def can be either a hash, in which case the keys
  # will be returns.
  def cols_from_report_def(report_def)
    cols = []
    report_def.each do |column_def|
      column_def.keys.each { |k| cols << k }
    end
    cols
  end

  # Returns a hash representation of columns and values, derived
  # from the report_def.
  # When the report_def contains a hash, the value is a lambda.
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