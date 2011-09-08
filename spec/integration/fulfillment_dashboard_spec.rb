require_relative '../spec_helper'

describe "admin fulfillment dashboard" do

  before(:all) do
    @email = 'admin@mandala-designs.com'
    @password = 'the_password'
  end
  
  before(:each) do
    ensure_admin(@email, @password)

    # login
    visit '/login'
    puts page.html
    puts current_path
    fill_in 'Email', :with => @email
    fill_in 'Password', :with => @password
    click_button 'Log In'

  end

  it 'welcomes the user' do

    visit '/admin/fulfillment/dashboard'
    puts current_path
    puts page.html
  end
end

# Make sure an admin user exists
def ensure_admin(email, password)
  admin = User.find_by_email(email)

  if (!admin)
    admin = User.create! :email => email, :password => password
    role = Role.find_or_create_by_name "admin"
    admin.roles << role
    admin.save!
  else
    admin.password = password
    admin.save!
  end

  test_user = User.find_by_email(email)
  test_user.valid_password?(password).should == true
end