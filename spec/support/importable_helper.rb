require_relative '../spec_helper'

shared_examples "an importable file" do |klass, record_length, ext|


  before :all do
    @import_class = klass
    @record_length = record_length
    @ext = ext
  end

  before :each do
    @order_1 = eval create_order_1
    @order_2 = eval create_order_2

    @order_1.line_items.each { |li| LineItem.find_by_id(li.id).should == li}

    @sample_file = {
        @import_class.ftp_dirs.first.to_sym => eval(outgoing_contents)
    }
    if @import_class.ftp_dirs.count > 1
      @sample_file[@import_class.ftp_dirs.last.to_sym] = eval(test_contents)
    end
  end
  

  context "when defining the import class" do
    it "should have the correct record length" do
      @import_class.record_length.should == @record_length
    end

    it "should have the correct extension" do
      @import_class.ext.should == @ext
    end

    it "should have the correct file mask" do
      @import_class.file_mask.should == "*#{@ext}"
    end
  end

  context "when working with remote files" do
    before :all do

      @file_names = {
          @import_class.ftp_dirs.first.to_sym => outgoing_file
      }
      if @import_class.ftp_dirs.count > 1
        @file_names[@import_class.ftp_dirs.last.to_sym] = incoming_file
      end

      @remote_dir = {}
      @import_class.ftp_dirs.each do |dir|
        @remote_dir[dir.to_sym] = ["-rw-rw-rw-   1 user     group         128 Aug  3 13:30 #{@file_names[dir.to_sym]}"]
      end
    end

    before :each do
      @client = double('CdfFtpClient')
      CdfFtpClient.should_receive(:new).any_number_of_times.and_return(@client)

      @po_files = {}

      @import_class.ftp_dirs.each do |dir|
        file_name = @file_names[dir.to_sym].gsub(/fbc$/, 'fbo')
        po_file = PoFile.create(:file_name => file_name)
        @po_files[dir.to_sym] = {
            :file_name => file_name,
            :file => po_file
        }
        PoFile.should_receive(:find_by_file_name!).any_number_of_times.with(file_name).and_return(po_file)
      end

    end


    context "and there are no files on the server" do
      it "should count 0 files" do
        ImportFileHelper.should_have_remote_file_count(@client, @import_class, 0) do |client|
          @import_class.ftp_dirs.each do |dir|
            remote_dir = "#{dir}"
            client.should_receive(:dir).with(remote_dir, ".*#{@ext}").once.and_return([])
          end
          client.should_receive(:close).once.and_return(nil)
        end
      end
    end

    context "and there is 1 import files on the server" do
      before :each do
        ImportFileHelper.init_client(@client, @ext, @file_names, @remote_dir, @sample_file, @import_class.ftp_dirs)
      end

      it "should count only the files ending with the correct extension" do
        ImportFileHelper.should_have_remote_file_count(@client, @import_class, @import_class.ftp_dirs.count)
      end

      context "and the import file is downloaded" do
        before :each do
          @downloaded = @import_class.download
          @import_file = @import_class.find_by_file_name @file_names.first
        end

        after :each do
          @import_class.all.each { |file| file.destroy }
        end


        it "should have the right data" do
          @import_file.data.should == @import_class.add_delimiters(@sample_file[@import_class.ftp_dirs.first.to_sym])
        end

        it "should have 0 versions" do
          @import_file.versions.count.should == 0
        end

        it "should create a new version when downloading a second time" do
          if @import_class.supports_versioning?
            remote_file_count = @file_names.size
            @import_class.needs_import.count.should == remote_file_count
            @downloaded.size.should == remote_file_count
            @downloaded.first.versions.size.should == 0

            @import_class.needs_import.count.should == remote_file_count
            @import_class.needs_import.first.should == @downloaded.first
            downloaded = @import_class.download
            new_import_file = @import_class.find_by_file_name @file_names.first
            new_import_file.versions.count == 1
            new_import_file.versions.first.file_name.should == @sample_file[@import_class.ftp_dirs.first.to_sym] + ".1"
          end
        end

        it "should have correct record length chars in each line" do
          @import_file.data.split(/\n/).each do |line|
            line.chomp.length.should == @record_length
          end
        end

      end

      context "and a file with the same name has already been downloaded" do
        before :each do
          @import_class.download
          @orig_import_file = @import_class.find_by_file_name @file_names.first
        end

        it "should make the existing @import_class old version the new file" do
          if @import_class.supports_versioning?
            @orig_import_file.versions.should == []
            @orig_import_file.parent.should == nil

            @import_class.download

            @orig_import_file.reload
            @orig_import_file.parent.should_not == nil
            @orig_import_file.versions.should == []

            @import_class.count.should == (@file_names.size * 2)

            @import_class.where(:file_name => @file_names.first).count.should == 1
            import_file = @import_class.find_by_file_name @file_names.first
            import_file.versions.count.should == 1
          end
        end
      end

      context "and the file is imported" do

        context "and there are no files to import" do
          it "should have no files that need import" do
            @import_class.needs_import.count.should == 0
          end
        end

        context "and there are files to import" do

          before :each do
            @import_class.download
            @import_class.needs_import.count.should > 0
            @first_import_file = @import_class.needs_import.first
            @parsed = @first_import_file.parsed

            @order_1.should_not == nil
            @order_2.should_not == nil
          end

          it "should have the orders to be tested" do
            Order.all.should == [@order_1, @order_2]
            Order.find_by_number(@order_1.number).should_not == nil
          end

          it "should import files one by one" do
            @first_import_file.import.should_not == nil
            @first_import_file.imported_at.should_not == nil
            @import_class.needs_import.count.should == @file_names.count-1
          end

          it "should import all files" do
            imported = @import_class.import_all
            imported.size.should == @file_names.size
            @import_class.all.count.should == imported.size
            @import_class.needs_import.count.should == 0
          end

          context "and asn file is imported" do
            before :each do
              @first_import_file.import
            end

            it "should return the correct data" do
              @first_import_file.data.should == @import_class.add_delimiters(@sample_file[@import_class.ftp_dirs.first.to_sym])
            end

            it "should import the correct file name" do
              @first_import_file.file_name.should == @file_names[@import_class.ftp_dirs.first.to_sym]
            end

            it "should validate import results" do
              validations.each do |v|
                puts "Validates #{v}"
                send(v, @parsed, @first_import_file)
              end
            end

          end

        end
      end

    end

  end

end