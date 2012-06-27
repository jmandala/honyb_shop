require 'spec_helper'

describe Importable do
  it "should download all files" do                # check return values? Would need to just hard code results - is that worth checking?
    Downloader.download_poa_files

    Downloader.download_asn_files

    Downloader.download_cdf_invoice_files
  end
end