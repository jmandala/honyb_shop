FactoryGirl.define do

  factory :poa_file do
    file_name "hb-#{Time.now.strftime("%y%m%d%H%M%S")}.fbc"
  end

  Rails.logger.debug 'hello poa'
end


