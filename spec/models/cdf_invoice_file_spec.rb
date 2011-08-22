require "spec_helper"

describe CdfInvoiceFile do

  before(:all) do
    CdfInvoiceFile.all.each &:destroy
  end

  after(:all) do
    CdfInvoiceFile.all.each &:destroy
  end

  context "when defining an CdfInvoiceFiled" do
    it "should specify a record length of 80" do
      CdfInvoiceFile.record_length.should == 80
    end

    it "should specify an extension of 'BIN'" do
      CdfInvoiceFile.ext.should == ".BIN"
    end

    it "should define a file mask of '*.BIN'" do
      CdfInvoiceFile.file_mask.should == "*.BIN"
    end
  end

  context "when working with remote files" do
    before(:all) do
      @sample_file = "0100001169797800000INGRAM BK CO 110822INVOICE COMMUNICATIONS                    
150000210003868                   20N2730     254410500020110822                
450000310003868                   0373200005 000010000499 0035 0000032420110822 
460000410003868                                              9780373200009      
48000051000386820110822HQPB FAMOUS FIRS00000R483688864            43        0000
4900006100038681ZTESTTRACKCI018370000   0000032400000000000000000000000000000324
450000710003868                   0373200005 000010000499 0035 0000032420110822 
460000810003868                                              9780373200009      
48000091000386820110822HQPB FAMOUS FIRS00000R746668282            41        0000
4900010100038681ZTESTTRACKCI018360000   0000032400000000000000000000000000000324
550001110003868     0000900002000002TESTCI0001       0000000                    
570001210003868     000000648      00000000000000000000000000          000000648
150000110003869                   20N2730            00020110822                
450000210003869                   555887564X 000010000000 0000 0000000020110822 
460000310003869                                              9785558875645      
48000041000386920110822 ORDER CHARGE   00000R483688864            43        0000
450000510003869                   5558875666 000010000065 0000 0000006520110822 
460000610003869                                              9785558875669      
48000071000386920110822 PER PIECE CHARG00000R483688864            43        0000
4900008100038691ZTESTTRACKCI018370000   0000000000000100000650000000000000000066
450000910003869                   555887564X 000010000000 0000 0000000020110822 
460001010003869                                              9785558875645      
48000111000386920110822 ORDER CHARGE   00000R746668282            41        0000
450001210003869                   5558875666 000010000065 0000 0000006520110822 
460001310003869                                              9785558875669      
48000141000386920110822 PER PIECE CHARG00000R746668282            41        0000
4900015100038691ZTESTTRACKCI018370000   0000000000000200000650000000000000000067
550001610003869     0001500004000004TESTCI0001       0000000                    
570001710003869     000000000      00000030000130000000000000          000000133
95000180000000000006000020000000006                                             "
    end

    before(:each) do
      @client = double('CdfFtpClient')
      CdfFtpClient.stub(:new).and_return(@client)
    end

    context "and there are no ASN files on the server" do
      it "should count 0 files" do
        @client.should_receive(:connect)
        CdfInvoiceFile.should_receive(:remote_file_path).any_number_of_times.and_return('test')
        CdfInvoiceFile.remote_files.count.should == 0
      end
    end

    context "and there is 1 Invoice file on the server" do
      before(:each) do

        @outgoing_files = [
            "drw-rw-rw-   1 user     group           0 Aug  3 21:52 ..",
            "drw-rw-rw-   1 user     group           0 Aug  3 21:52 .",
            "-rw-rw-rw-   1 user     group         128 Aug  3 13:30 05503677.PBS",
            "-rw-rw-rw-   1 user     group         128 Aug  3 13:30 05503670.pbs",
            "-rw-rw-rw-   1 user     group        1872 Aug  3 20:30 05536017.BIN",
            "-rw-rw-rw-   1 user     group        1872 Aug  3 20:30 05536010.bin"
        ]

        @ftp = double('ftp-server')
        @ftp.stub(:chdir).with('outgoing').and_return(nil)
        @ftp.stub(:list).with(CdfInvoiceFile.file_mask).and_return(@outgoing_files)
        @ftp.stub(:delete).and_return(nil)
        @client.stub(:connect).and_yield(@ftp)
      end

      it "should count only the files ending with .BIN" do
        CdfInvoiceFile.remote_files.size.should == 1
      end

      context "file is downloaded" do
        before(:each) do
          @file_name = '05536017.BIN'
          cdf_invoice_file = CdfInvoiceFile.create_path(@file_name)
          @ftp.should_receive(:gettextfile).any_number_of_times.with(@file_name, cdf_invoice_file).and_return do
            file = File.new(cdf_invoice_file, 'w')
            file.write @sample_file
            file.close
            nil
          end
        end

        it "should have the correct number of records after the download" do
          CdfInvoiceFile.download
          cdf_invoice_file = CdfInvoiceFile.find_by_file_name @file_name
          cdf_invoice_file.data.should == @sample_file
        end

        it "should download the file, create an CdfInvoiceFile record, and delete the file from the server" do
          @ftp.should_receive(:delete).once

          CdfInvoiceFile.needs_import.count.should == 0
          downloaded = CdfInvoiceFile.download
          downloaded.size.should == 1
          downloaded.first.versions.size.should == 0

          CdfInvoiceFile.needs_import.count.should == 1
          CdfInvoiceFile.needs_import.first.should == downloaded.first
          CdfInvoiceFile.needs_import.first.file_name.should == @file_name
        end

        it "should have 80 chars in each line" do
          CdfInvoiceFile.download.size.should == 1
          CdfInvoiceFile.needs_import.first.data.split(/\n/).each do |line|
            line.length.should == 80
          end
        end

        context "and a Invoice file with the same name has already been downloaded" do
          before(:each) do
            CdfInvoiceFile.download
          end

          it "should make the existing CdfInvoiceFile old version the new file" do
            orig_cdf_invoice_file = CdfInvoiceFile.find_by_file_name @file_name
            orig_cdf_invoice_file.versions.should == []
            orig_cdf_invoice_file.parent.should == nil

            CdfInvoiceFile.download

            orig_cdf_invoice_file.reload
            orig_cdf_invoice_file.parent.should_not == nil
            orig_cdf_invoice_file.versions.should == []

            CdfInvoiceFile.count.should == 2

            CdfInvoiceFile.where(:file_name => @file_name).count.should == 1
            CdfInvoiceFile.where(:file_name => @file_name).count.should == 1
            cdf_invoice_file = CdfInvoiceFile.find_by_file_name @file_name
            cdf_invoice_file.versions.count.should == 1
          end
        end

        context "and the file is imported" do

          context "and there are no Invoice files to import" do
            it "should have no files that need import" do
              CdfInvoiceFile.needs_import.count.should == 0
            end
          end

          context "and there are Invoice files to import" do
            before(:each) do
              @order_1 = FactoryGirl.create(:order, :number => 'R374103387')
              @order_2 = FactoryGirl.create(:order, :number => 'R674657678')

              @product = Factory(:product, :sku => '978-0-37320-000-9', :price => 10, :name => 'test product')
              @variant = @product.master
              @line_item = Factory(:line_item, :variant => @variant, :price => 10, :order => @order_1)
              LineItem.should_receive(:find_by_id!).any_number_of_times.with("1").and_return(@line_item)

              CdfInvoiceFile.download
              CdfInvoiceFile.needs_import.count.should > 0
              @cdf_invoice_file = CdfInvoiceFile.needs_import.first
              @parsed = @cdf_invoice_file.parsed
            end

            it "should import files one by one" do
              @cdf_invoice_file.import!.should == nil
              @cdf_invoice_file.imported_at.should_not == nil
              CdfInvoiceFile.needs_import.count.should == 0
            end

            it "should import all files" do
              imported = CdfInvoiceFile.import_all
              imported.size.should == 1
              CdfInvoiceFile.all.count.should == 1
              CdfInvoiceFile.needs_import.count.should == 0
            end

            context "and an invoice file is imported" do
              before(:each) do
                @cdf_invoice_file.import!
              end
              it "should return the correct data" do
                @cdf_invoice_file.data.should == CdfInvoiceFile.add_delimiters(@sample_file)
              end

              it "should import the CdfInvoiceFile data" do
                should_import_cdf_invoice_file_data(@parsed, @cdf_invoice_file, @file_name)
              end

              it "should import the CdfInvoiceHeader data" do
                should_import_cdf_invoice_header(@parsed, @cdf_invoice_file)
              end
              
              it "should import the CdfInvoiceIsbnDetail data" do
                should_import_cdf_invoice_isbn_detail(@parsed, @cdf_invoice_file)
              end
              it "should import the CdfInvoiceEanDetail data" do
                should_import_cdf_invoice_ean_detail(@parsed, @cdf_invoice_file)
              end
              
            end

          end
        end

      end

    end

  end
end

def should_import_cdf_invoice_ean_detail(parsed, cdf_invoice_file)
  parsed[:cdf_invoice_ean_detail].each do |record|
    db_record = CdfInvoiceEanDetail.find_self cdf_invoice_file, record[:sequence]
    db_record.should_not == nil
    db_record.cdf_invoice_file.should == cdf_invoice_file
    db_record.record_code.should == '46'

    [:ean_shipped].each { |field| ImportFileHelper.should_match_text(db_record, record, field) }

    [:invoice_number].each { |field| ImportFileHelper.should_match_i(db_record, record, field) }

  end
end
def should_import_cdf_invoice_isbn_detail(parsed, cdf_invoice_file)
  parsed[:cdf_invoice_isbn_detail].each do |record|
    db_record = CdfInvoiceIsbnDetail.find_self cdf_invoice_file, record[:sequence]
    db_record.should_not == nil
    db_record.cdf_invoice_file.should == cdf_invoice_file
    db_record.record_code.should == '45'

    [:isbn_10_shipped].each { |field| ImportFileHelper.should_match_text(db_record, record, field) }

    [:ingram_list_price,
     :discount,
     :net_price].each { |field| ImportFileHelper.should_match_money(db_record, record, field) }

    [:invoice_number,
     :quantity_shipped].each { |field| ImportFileHelper.should_match_i(db_record, record, field) }

    [:metered_date].each { |field| ImportFileHelper.should_match_date(db_record, record, field, "%Y%m%d") }

  end
end

def should_import_cdf_invoice_header(parsed, cdf_invoice_file)
  parsed[:cdf_invoice_header].each do |record|
    db_record = CdfInvoiceHeader.find_self cdf_invoice_file, record[:sequence]
    db_record.should_not == nil
    db_record.cdf_invoice_file.should == cdf_invoice_file
    db_record.record_code.should == '15'

    [:sequence].each { |field| ImportFileHelper.should_match_text(db_record, record, field) }
    [:invoice_number, :warehouse_san, :company_account_id_number].each do |field|
      ImportFileHelper.should_match_i(db_record, record, field)
    end

    [:invoice_date].each { |field| ImportFileHelper.should_match_date(db_record, record, field, "%Y%m%d") }
  end
end

def should_import_cdf_invoice_file_data(parsed, cdf_invoice_file, file_name)
  all = parsed[:header]
  all.should_not == nil
  all.size.should == 1
  parsed = all.first

  db_record = cdf_invoice_file
  db_record.record_code.should == '01'
  db_record.created_at.should_not == nil

  [:record_code,
   :sequence,
   :file_source,
   :ingram_file_name].each do |field|
    ImportFileHelper.should_match_text(db_record, parsed, field)
  end

  [:ingram_san].each { |field| ImportFileHelper.should_match_i(db_record, parsed, field) }
  [:creation_date].each { |field| ImportFileHelper.should_match_date(db_record, parsed, field) }
  db_record.file_name.should == file_name
  db_record.versions.should == []
  db_record.parent.should == nil
end
