User.class_eval do
  
  belongs_to :affiliate
  delegate :affiliate_key, :to => :affiliate, :allow_nil => true
  
end
