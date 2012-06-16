Admin::UsersController.class_eval do

  NIL_RECORD = OpenStruct.new(:id => -1, :affiliate_key => "** None **")

  # Adds all affiliates to the scope for selection
  def edit_affiliate
    @affiliates = Affiliate.all
    @affiliates << NIL_RECORD
    @affiliates << OpenStruct.new(:id => 2, :affiliate_key => "error")
  end

  def show_affiliate
    render :action => :update_affiliate
  end
  # Assigns the given affiliate
  def update_affiliate
    begin

      affiliate_id = params[:user][:affiliate_id].to_i
      if affiliate_id == NIL_RECORD.id
        @user.affiliate = nil
        @user.save!
        return
      end

      @user.affiliate = Affiliate.find(affiliate_id)
      @user.save!
    rescue ActiveRecord::RecordNotFound => e
      flash[:error] = t('affiliate.not_found')
      render :nothing => true
    end

  end
end