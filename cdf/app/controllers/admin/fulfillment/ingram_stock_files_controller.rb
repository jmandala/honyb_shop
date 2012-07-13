class Admin::Fulfillment::IngramStockFilesController < Admin::Fulfillment::ImportController
  before_filter :hide_parsed, :only => [:show]

  def index
    begin
      @downloadable = []
      @collection = []
      params[:search] ||= {}
      @search = model_class.metasearch(params[:search], :distinct => true)

      @downloadable = model_class.remote_files
      @hide_download_all_button = true

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
    rescue => e
      flash[:error] = "An error has occurred: #{e.message}"
      logger.error e.message
      logger.error e.backtrace
    end
  end

  def import
    if disable_delay_job?
      Delayed::Worker.delay_jobs = false
    end

    model_class.delay(:queue => 'download').delayed_import @object

    if disable_delay_job?
      Delayed::Worker.delay_jobs = true
    else
      @object.download_queued_at = Time.now
      @object.save!
    end

    flash[:notice] = "Successfully imported #{@object.file_name}"

    respond_with(@object) do |format|
      format.html { redirect_to polymorphic_url([:admin, :fulfillment, object_name]) }
      format.js { render :layout => false }
    end
  end

  def download
    begin
      if disable_delay_job?
        Delayed::Worker.delay_jobs = false
      end
      result = model_class.delay(:queue => 'download').download_file nil, @object.file_name

      if result
        if disable_delay_job?
          Delayed::Worker.delay_jobs = true
        else
          @object.download_queued_at = Time.now
          @object.save!
        end

        flash[:notice] = "Download Queued for #{@object.file_name}."
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

  private

  # disable delay job by default in development - set enable_delay_job_in_development in config.yml to override
  def disable_delay_job?
    Rails.env == "development" && !Cdf::Config[:enable_delay_job_in_development]
  end

end