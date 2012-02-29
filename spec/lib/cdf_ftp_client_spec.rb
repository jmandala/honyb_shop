require_relative '../spec_helper'
require 'net/ftp'

describe CdfFtpClient do

  before(:all) do
    Cdf::Config.set(:cdf_ftp_server => 'test_ftp_server')
    Cdf::Config.set(:cdf_ftp_user => 'test_ftp_user')
    Cdf::Config.set(:cdf_ftp_password => 'test_ftp_password')
    @default_client = CdfFtpClient.new
  end

  context "when using default initialization" do

    it "has the ftp server name specified in Cdf::Config" do
      @default_client.server.should == Cdf::Config[:cdf_ftp_server]
    end

    it "has the user name Cdf::Config" do
      @default_client.user.should == Cdf::Config[:cdf_ftp_user]
    end
    it "has the password Cdf::Config" do
      @default_client.password.should == Cdf::Config[:cdf_ftp_password]
    end

    it "should be in mock mode" do
      @default_client.test?.should == false
      @default_client.mock?.should == true
      @default_client.live?.should == false
    end
  end

  context "when connecting to server" do

    context "when run in test mode" do

      before :all do
        Cdf::Config.set(:cdf_run_mode => 'test')
      end
      
      context "when credentials are valid" do

        before(:each) do
          
          @client = CdfFtpClient.new
        end

        it "should have valid server" do
          @client.valid_server?.should == true
        end

        it "should have valid credentials" do
          @client.valid_credentials?.should == true
        end

        it "should connect and list contents" do
          list = nil
          @client.connect do |ftp|
            list = ftp.list
          end
          list.should_not == nil
          list.size.should == 6
        end
        
        it "should stay open when keep_alive is set" do
          @alive_client = CdfFtpClient.new({:keep_alive => true})
          @alive_client.dir
          @alive_client.open?.should == true
          @alive_client.close
          @alive_client.open?.should == false
          
        end
        it "should get a list of remote files" do
          @client.outgoing_files.should_not == nil
          @client.test_files.should_not == nil
          @client.archive_files.should_not == nil
          @client.incoming_files.should_not == nil
        end
        
        it "should put a file the archive and then download it and cleanup" do
          content = "#{rand(50)}-#{rand(50)}-#{rand(50)}"
          file_name = 'test.txt'
          File.open(file_name, 'w') { |f| f.write content }
          content.should ==  File.read(file_name)
          
          alive = CdfFtpClient.new({:keep_alive => true})
          
          alive.put('~/archive', file_name)
          
          files = alive.get_all('~/archive', '.*\.txt', 'download_dir')
          files.should == [file_name]
          
          new_file = File.join('download_dir', file_name)
          
          content.should == File.read(new_file)
          
          File.delete file_name
          File.delete new_file
          FileUtils.rm_f 'download_dir'
          
          alive.delete('~/archive', file_name)
          alive.close
        end
        
      end

      context "when server credentials are invalid" do
        before(:each) do
          Cdf::Config.set(:cdf_ftp_server => 'badconnection')
          @client = CdfFtpClient.new
        end

        it "should report invalid server" do
          @client.valid_server?.should == false
        end

        it "should not connect" do
          list = nil
          error = nil
          begin
            @client.connect do |ftp|
              list = ftp.list
            end
          rescue => e
            error = e
          end

          error.class.should == Cdf::InvalidServer
          list.should == nil
        end
      end

      context "when user credentials are invalid" do
        before(:each) do
          Cdf::Config.set(:cdf_ftp_user => 'bad-user')
          Cdf::Config.set(:cdf_ftp_password => 'bad-password')
          Cdf::Config.set(:cdf_ftp_server => 'ftp1.ingrambook.com')
          @client = CdfFtpClient.new
        end

        it "should report invalid credentials" do
          @client.valid_credentials?.should == false

          error = nil
          begin
            @client.connect
          rescue => e
            error = e
          end
          error.class.should == Cdf::InvalidCredentials
          error.message.should == "Unable to establish connection to server: '#{Cdf::Config[:cdf_ftp_server]}' with username: #{Cdf::Config[:cdf_ftp_user]}."
        end

        context "when run mode is :mock" do
          before(:each) do
            Cdf::Config.set(:cdf_run_mode => :mock)
            @mock_client = CdfFtpClient.new
          end

          it "should know it's in mock mode" do
            @client.run_mode.should == :mock
            @client.mock?.should == true
          end

          it "should connect just fine" do
            files = []
            @mock_client.connect do |ftp|
              files << 'a test'
            end
            files.size.should == 0
          end
        end

      end
    end
  end
end