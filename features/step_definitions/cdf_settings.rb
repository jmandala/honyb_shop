# define settings
Given /^(CDF .*): (.*)$/ do |key, value|
  key = to_sym key
  if Spree::Config.get(key).nil? || Spree::Config.get(key) == ''
    Spree::Config.set({key => value.strip})
  end
end
