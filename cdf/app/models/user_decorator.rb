#noinspection RubyArgCount
User.class_eval do

  before_validation :auto_set_password_confirmation

  User.const_set(:COMPLIANCE_EMAIL, "compliance.test@honyb.com") unless User.const_defined? :COMPLIANCE_EMAIL

  # Creates a user to assign to compliance test orders
  def self.compliance_tester!
    token = User.generate_token(:persistence_token)
    #noinspection RubyResolve
    User.create(:email => COMPLIANCE_EMAIL, :password => token, :password_confirmation => token, :persistence_token => token)
  end

  def compliance_tester?
    #noinspection RubyResolve
    email == COMPLIANCE_EMAIL
  end

  private
  def auto_set_password_confirmation
    self.password_confirmation = self.password if self.password
  end


end
