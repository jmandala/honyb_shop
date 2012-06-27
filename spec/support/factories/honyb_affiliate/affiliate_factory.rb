FactoryGirl.define do

  factory :affiliate do 
    affiliate_key {String.random(10)}
    name {String.random(10)}
  end
end
