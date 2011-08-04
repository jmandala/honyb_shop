# define settings
Given /^(CDF .*): (.*)$/ do |key, value|
  key = to_sym key
  if Spree::Config[key] == ''
    Spree::Config.set({key => value.strip})
  end
end
