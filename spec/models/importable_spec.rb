require 'spec_helper'

describe Importable do
  it "should download all files" do
    Importable::Downloader.download_all_files
  end
end