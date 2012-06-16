Admin::UsersController.class_eval do

  NIL_RECORD = OpenStruct.new(:id => -1, :affiliate_key => I18n.t(:none, :scope => :global)) unless Admin::UsersController.const_defined? :NIL_RECORD

  # Adds all affiliates to the scope for selection
  def edit_affiliate
    @affiliates = Affiliate.all
    @affiliates.unshift NIL_RECORD
  end

  def show_affiliate
    render :action => :update_affiliate
  end

  # Creates a new affiliate with the key provided and assigns it to this user
  # Error if affiliate key is blank, or already used
  def create_affiliate
    affiliate_key = params[:user][:affiliate_key]

    if affiliate_key.blank?
      flash[:error] = t('affiliate.key.not_blank')
      render :nothing => true
      return
    end

    if Affiliate.find_by_affiliate_key(affiliate_key)
      flash[:error] = t('affiliate.key.not_unique')
      render :nothing => true
      return
    end

    begin
      Affiliate.validate_affiliate_key(affiliate_key)
    rescue ArgumentError => e
      flash[:error] = e.message
      render :nothing => true
      return
    end

    # Create Affiliate
    User.transaction do
      @user.affiliate = Affiliate.create(:affiliate_key => affiliate_key)
      @user.save!
    end


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