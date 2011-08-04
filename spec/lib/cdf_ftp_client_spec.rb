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

  context "when using mocked initialization" do

    it "should login to ftp server" do
      ftp = double('FTP server').as_null_object

      Net::FTP.should_receive(:new).and_return(ftp)

      ftp.should_receive(:login).with(@client.user, @client.password)
      ftp.should_receive(:close)
      @client.connect
    end
  end
end