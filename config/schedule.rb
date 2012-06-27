# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

every 30.minutes do
  runner "Downloader.download_poa_files"
end

every 4.hours do
  runner "Downloader.download_asn_files"
end

every 4.hours do
  runner "Downloader.download_cdf_invoice_files"
end

every 4.hours do
  runner "Downloader.download_and_import_stock_delta_files"
end

# need to add specific time and date for this
every 1.weeks do
  runner "Downloader.download_and_import_inventory_file"
end

# Learn more: http://github.com/javan/whenever
