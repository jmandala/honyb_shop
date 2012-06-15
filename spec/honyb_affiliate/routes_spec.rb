require 'spec_helper'

describe 'routes', :type => :routing do

  it "routes /admin/user/:id/edit_affiliate Admin::UsersController#edit_affiliate for user" do
    {:get => "/admin/users/1/edit_affiliate"}.should route_to(
                                            :action => "edit_affiliate",
                                            :controller => "admin/users",
                                            :id => '1'
                                        )
  end
  
end