# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

def production?
  @environment == 'production'
end

job_type :runner, "cd :path && RAILS_ENV=:environment :bundler exec :task"

if production?
  every 30.minutes do
    runner "Downloader.download_poa_files"
  end

  every 4.hours do
    runner "Downloader.download_asn_files"
  end

  every 4.hours do
    runner "Downloader.download_cdf_invoice_files"
  end
end

every 4.hours do
  runner "Downloader.download_and_import_stock_delta_files"
end

# setting the full file download for 3AM every Sunday, but which time zone will this use? Local time zone of the server (US - Eastern) or GMT? Or something else entirely?
every :sunday, :at => '3am' do
  runner "Downloader.download_and_import_inventory_file"
end

# Learn more: http://github.com/javan/whenever
