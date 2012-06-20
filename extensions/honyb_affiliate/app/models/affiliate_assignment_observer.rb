class AffiliateAssignmentObserver < ActiveRecord::Observer
  observe :order
  
  # If there is a current affiliate, and the order doesn't yet have an affifliate assigned, 
  # assign it
  def after_create(order)
    if Affiliate.current.nil? || order.affiliate
      return
    end
    
    order.affiliate = Affiliate.current
    order.save!
  end
end