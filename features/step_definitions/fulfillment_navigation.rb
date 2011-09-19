When /^I import all files$/ do
  CdfComplianceHelper.import_all
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


When /^I sign in as "(.*)\/(.*)"$/ do |email, password|
  When %{I go to the sign in page"}
  And %{I fill in "Email" with "#{email}"}
  And %{I fill in "Password" with "#{password}"}
  And %{I press "Log In"}
end

Given /^I sign in with email "([^"]*)" and password "([^"]*)"$/ do |email, password|
  ensure_admin(email, password)
  visit('/login')
  within("#existing-customer") do
    fill_in 'Email', :with => email
    fill_in 'Password', :with => password
  end
  click_button('Log In')

#noinspection RubyResolve
  current_path.should == products_path
end

When /I visit the admin page/ do  
  visit '/admin'
  page.should have_content('Overview')

  visit '/admin/fulfillment/dashboard'
  page.should have_link('Dashboard')
  page.should have_link('PO Files')
  page.should have_link('POA Files')
  page.should have_link('ASN Files')
  page.should have_link('Invoice Files')
end
