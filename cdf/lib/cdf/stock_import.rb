class Cdf::StockImport

  FixedWidth.define :stock_import do |d|
    d.template :asn_defaults do |t|
      t.record_code 2
      t.client_order_id 22
    end

    d.header(:align => :left) do |h|
      h.trap { |line| line[0, 2] == 'CR' }
      h.record_code 2
      h.company_account_id_number 10
      h.total_order_count 8
      h.file_version_number 10
      h.spacer 170
    end
  end

  def file_name
    'stockv2@ingram.dat'
  end
  
  def parsed
    path = File.join CdfConfig::data_lib_in_root(created_at.strftime("%Y")), file_name
    FixedWidth.parse(File.new(path), :stock_import)
  end


end
