# define settings
Given /^(CDF .*): (.*)$/ do |key, value|
  key = to_sym key
  if Cdf::Config.get(key) != value.strip
    Cdf::Config.set({key => value.strip})
  end
end
