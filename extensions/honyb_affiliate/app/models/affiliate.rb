# Represents an organization that promotes
# books and receives commissions on sales
#
# To link sales to the correct affiliate, the affiliate's 'affiliate_key'
# must be present in the initial link to this site.
# Subsequent visits will maintain the same affiliate
# id unless it is explicitly set to something else
# by a new visit.
#
# If no affiliate_key is present, the Affiliate will not be set.
# Once an affiliate is set, it can be accessed from the Thread by
# Affiliate#current.
#
# Example Urls
# ------------
# /embed/h-the-affiliate-id/ => affiliate_key = 'the-affiliate-id'
# 
class Affiliate < ActiveRecord::Base

  has_many :users
  has_many :orders
  
  has_attached_file :logo, :url => "/spree/honyb/affiliates/:attachment/:id/:style_:filename",
      :styles => { :embed => 'x16'},
      :default_style => :embed
  
  validates :name, :presence => true
  validates_uniqueness_of :affiliate_key
  validates_uniqueness_of :name
  validates_attachment_content_type :logo, :content_type => %w(image/png image/jpg image/gif)
  
  def self.current
    Thread.current[:affiliate]
  end

  def self.current=(affiliate)
    Thread.current[:affiliate] = affiliate
  end

  # Initializes the current Affilate using the parameters
  def self.init(affiliate_key)
    return if affiliate_key.nil?

    affiliate = Affiliate.find_by_affiliate_key! affiliate_key
    self.current = affiliate
  end

  # Returns true if there is a #current Affiliate
  def self.has_current?
    !current.nil?
  end

  # Returns error message if key is not a valid affiliate key
  def self.validate_affiliate_key(key)
    valid_pattern = %r(^[\w\-\_]{6,30})
    return true if key.match(valid_pattern)
    raise ArgumentError, "Affiliate Key should be 6-30 characters and contain only letters, numbers, underscores or dashes."
  end
  
end