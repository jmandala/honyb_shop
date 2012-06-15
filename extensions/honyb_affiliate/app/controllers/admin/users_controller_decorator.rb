Admin::UsersController.class_eval do

  # Adds all affiliates to the scope for selection
  def edit_affiliate
    @affiliates = Affiliate.all
  end
end