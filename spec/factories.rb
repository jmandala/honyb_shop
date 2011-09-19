require 'spree_core/testing_support/factories'

puts "running factories.rb"

Dir["#{File.dirname(__FILE__)}/factories/**"].each do |f|
  fp =  File.expand_path(f)
  #require fp
  puts "require #{fp}"
end
