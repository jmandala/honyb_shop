# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

every 30.minutes do
  runner "Importable::Downloader.download_poa_files"
end

every 4.hours do
  runner "Importable::Downloader.download_asn_files"
end

every 4.hours do
  runner "Importable::Downloader.download_cdf_invoice_files"
end

# Learn more: http://github.com/javan/whenever
