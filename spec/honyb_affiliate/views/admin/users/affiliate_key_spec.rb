require 'spec_helper'

describe "/admin/users/show", :type => :view do
  
  it "renders _affiliate_key.html.erb partial for each user" do
    
    user = Factory(:user, :email => "#{String.random(10)}@example.com")
    assign :user, user
    assign :object, user
    render
    puts rendered
    view.should render_template(:partial => "_affiliate_key")
  end
  
end