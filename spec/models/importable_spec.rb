require 'spec_helper'

describe Importable do
  it "should download all files" do                # check return values? Would need to just hard code results - is that worth checking?
    Importable::Downloader.download_poa_files

    Importable::Downloader.download_asn_files

    Importable::Downloader.download_cdf_invoice_files
  end
end