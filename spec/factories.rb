FactoryGirl.define do

  sequence :email do |n|
    "person#{n}@example.com"
  end

  factory :country do
    factory :us do
      iso_name 'UNITED STATES'
      iso 'US'
      name 'United States'
      iso3 'USA'
      numcode 840
    end

    factory :france do
      iso_name 'FRANCE'
      iso 'FR'
      name 'France'
    end
  end

  factory :state do
      factory :maine do
        name 'Maine'
        abbr 'ME'
        association :country, :factory => :us
    end
  end

  factory :address do
    address1 '10 Glidden Street'
    address2 'Apt. #1'
    alternative_phone '(207) 563-1471'
    city 'Newcastle'
    phone '(617) 297-2358'
    firstname 'John'
    lastname 'Doe'
    zipcode '04553'
    association :country, :factory => :us
    association :state, :factory => :maine
  end

  factory :order do
    shipment_state 'ready'
    association :bill_address, :factory => :address
    association :ship_address, :factory => :address
    email
  end

end
