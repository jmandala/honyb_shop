class Admin::Fulfillment::IngramStockFilesController < Admin::Fulfillment::ImportController
  before_filter :hide_parsed, :only => [:show]

  def index
    params[:search] ||= {}
    @search = model_class.metasearch(params[:search], :distinct => true)

    @downloadable = model_class.remote_files
    @hide_download_all_button = true

    @collection = []
    @downloadable.each do |file|
      file_name = CdfFtpClient.name_from_path(file)
      file_info = IngramStockFile.file_name_useful_to_honyb file_name
      if file_info[:useful_file]
        file_name = file_name.partition(".")[0] + ".dat"
        import_file = model_class.find_by_file_name(file_name)
        if import_file.nil?
          parsed_date = nil
          parsed_date = Date.strptime(file_info[:file_date], "%y%m%d") unless file_info[:full_file]
          import_file = model_class.create(:file_name => file_name, :file_size => CdfFtpClient.size_from_path(file), :file_date => parsed_date)
        else
          import_file.file_size = CdfFtpClient.size_from_path(file)     # update the file size if it had changed since the last time we've seen this file
          import_file.save
        end

        @collection << import_file
      end
    end

    respond_with @collection
  end

  def import
    begin
      if @object.downloaded_at.nil?
        result = model_class.download_file nil, @object.file_name

        if result
          result.downloaded_at = Time.now
          result.save!
          @object = result
        end
      end
      result = @object.import!
      flash[:notice] = "Imported #{@object.file_name}."

    rescue => e
      flash[:error] = "#{e.message}"

    end
    respond_with(@object) do |format|
      format.html { redirect_to polymorphic_url([:admin, :fulfillment, object_name]) }
      format.js { render :layout => false }
    end

  rescue Exception => e
    flash[:error] = "Failed to import #{@object.file_name}. #{e.message}"
    logger.error e.backtrace
    raise e
  end


  def download
    begin
      result = model_class.download_file nil, @object.file_name

      if result
        result.downloaded_at = Time.now
        result.save!

        flash[:notice] = "Downloaded #{@object.file_name}."
      end

    rescue => e
      flash[:error] = "#{e.message}"
    end

    respond_with(@object) do |format|
      format.html { redirect_to polymorphic_url([:admin, :fulfillment, object_name]) }
      format.js { render :layout => false }
    end

    rescue Exception => e
      flash[:error] = "Failed to download #{@object.file_name}. #{e.message}"
      logger.error e.backtrace
      raise e
  end

  def hide_parsed
    @hide_parsed = true
  end

end