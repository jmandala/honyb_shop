# Represents an organization that promotes
# books and receives commissions on sales
#
# To link sales to the correct affiliate, the affiliate's 'honyb_id'
# must be present in the initial link to this site.
# Subsequent visits will maintain the same affiliate
# id unless it is explicitly set to something else
# by a new visit.
#
# If no honyb_id is present, the Affiliate will not be set.
# Once an affiliate is set, it can be accessed from the Thread by
# Affiliate#current.
#
# Example Urls
# ------------
# /embed/h-the-affiliate-id-b/ => honyb_id = 'the-affiliate-id'
# 
class Affiliate < ActiveRecord::Base

  def self.current
    Thread.current[:affiliate]
  end

  def self.current=(affiliate)
    Thread.current[:affiliate] = affiliate
  end

  # Initializes the current Affilate using the parameters
  def self.init(honyb_id)
    return if honyb_id.nil?

    affiliate = Affiliate.find_by_honyb_id! honyb_id
    self.current = affiliate

  end

  # Returns true if there is a #current Affiliate
  def self.has_current?
    !current.nil?
  end

end