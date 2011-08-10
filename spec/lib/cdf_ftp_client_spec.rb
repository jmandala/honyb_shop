require 'spec_helper'
require 'net/ftp'

describe CdfFtpClient do

  before(:each) do
    @client = CdfFtpClient.new
  end

  context "when using default initialization" do

    it "has the ftp server name specified in Spree::Config" do
      @client.server.should == Spree::Config.get(:cdf_ftp_server)
    end

    it "has the user name Spree::Config" do
      @client.user.should == Spree::Config.get(:cdf_ftp_user)
    end
    it "has the password Spree::Config" do
      @client.password.should == Spree::Config.get(:cdf_ftp_password)
    end
  end

  context "when connecting to server" do

    before(:each) do
      @ftp = double('FTP server').as_null_object
      Net::FTP.should_receive(:open).with(@client.server).and_return(@ftp)
    end

    it "should login and close" do
      @client.connect
    end
  end
end