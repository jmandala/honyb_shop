# Aggregates CdfInvoiceIsbnDetail and CdfInvoiceEanDetail records, and links to LineItems
class CdfInvoiceDetailTotal < ActiveRecord::Base
  include CdfInvoiceDetailRecord
  include Records

  belongs_to :cdf_invoice_isbn_detail, :dependent => :destroy
  belongs_to :cdf_invoice_ean_detail, :dependent => :destroy
  belongs_to :order
  belongs_to :line_item

  delegate :quantity_shipped, :isbn_10_shipped, :ingram_list_price, :discount, :net_price, :metered_date, :to => :cdf_invoice_isbn_detail
  delegate :ean_shipped, :to => :cdf_invoice_ean_detail

  def self.spec(d)
    d.cdf_invoice_detail_total do |l|
      l.trap { |line| line[0, 2] == '48' }
      l.template :cdf_invoice_defaults
      l.spacer 8
      l.title 16
      l.spacer 5
      l.client_order_id 22
      l.line_item_id_number 10
      l.spacer 4
    end
  end

  def before_populate(data)
    init_order(data)
    init_line_item(data)
    self.cdf_invoice_isbn_detail = CdfInvoiceIsbnDetail.find_nearest_before!(self.cdf_invoice_header, data[:__LINE_NUMBER__])
    self.cdf_invoice_ean_detail = CdfInvoiceEanDetail.find_nearest_before!(self.cdf_invoice_header, data[:__LINE_NUMBER__])
  end

  # Sets the line_item value using the line_item_id_number on this record
  # If blank, does nothing
  # CdfInvoiceDetailTotal
  # @param data [Hash] parsed data. Keys match definition in self#spec
  def init_line_item(data)

    line_item_id = data[:line_item_id_number].strip
    data.delete :line_item_id_number
    
    return if line_item_id.blank?
    
    self.line_item = LineItem.find_by_id!(line_item_id)
  end

  # Sets the order for this instance
  #
  # @param data [Hash] parsed data. Keys match definition in self#spec  
  def init_order(data)
    self.order = Order.find_by_number!(data[:client_order_id].strip)
    data.delete :client_order_id
  end
end
