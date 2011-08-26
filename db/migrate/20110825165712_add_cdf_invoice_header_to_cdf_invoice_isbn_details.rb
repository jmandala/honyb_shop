class AddCdfInvoiceHeaderToCdfInvoiceIsbnDetails < ActiveRecord::Migration
  def self.up
    [:cdf_invoice_isbn_details,
     :cdf_invoice_ean_details,
     :cdf_invoice_freight_and_fees,
     :cdf_invoice_detail_totals,
     :cdf_invoice_totals,
     :cdf_invoice_trailers
    ].each do |table|
      rename_column table, :cdf_invoice_file_id, :cdf_invoice_header_id
    end
  end

  def self.down
    def self.up
      [:cdf_invoice_isbn_details,
       :cdf_invoice_ean_details,
       :cdf_invoice_freight_and_fees,
       :cdf_invoice_detail_totals,
       :cdf_invoice_totals,
       :cdf_invoice_trailers
      ].each do |table|
        rename_column table, :cdf_invoice_header_id, :cdf_invoice_file_id 
      end
    end
  end
end
