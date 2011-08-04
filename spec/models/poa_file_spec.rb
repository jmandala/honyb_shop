require 'spec_helper'

describe PoaFile do

  before(:each) do
    @client = double('CdfFtpClient')
    CdfFtpClient.should_receive(:new).and_return(@client)
  end

  context "when there are no POA files on the server" do
    it "should count 0 files" do
      @client.should_receive(:connect)
      PoaFile.retrieve_count.should == 0
    end
  end

  context "when there is 1 POA files on the server" do
    it "should count only the files ending with .fbc" do
      ftp = double('ftp-server')
      ftp.should_receive(:chdir).with('outgoing').and_return(nil)
      outgoing_files = [
          "drw-rw-rw-   1 user     group           0 Aug  3 21:52 ..",
          "drw-rw-rw-   1 user     group           0 Aug  3 21:52 .",
          "-rw-rw-rw-   1 user     group         128 Aug  3 13:30 hb-110803182629.fbc",
          "-rw-rw-rw-   1 user     group        1872 Aug  3 20:30 hb-110804012651.fbo"
      ]
      ftp.should_receive(:list).
          with('*.fbc').
          and_return(outgoing_files)
      @client.should_receive(:connect).and_yield(ftp)
      PoaFile.retrieve_count.should == 1
    end
  end


end
