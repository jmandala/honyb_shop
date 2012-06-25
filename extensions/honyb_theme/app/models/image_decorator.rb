Image.class_eval do

  has_attached_file :attachment,
                    :styles => { :mini => 'x60>', :small => 'x100', :product => 'x320', :large => 'x600>' },
                    :default_style => :product,
                    :url => "/spree/products/:id/:style/:basename.:extension",
                    :path => ":rails_root/public/spree/products/:id/:style/:basename.:extension"
  
  
end