require 'spec_helper'

describe 'routes', :type => :routing do

  it "routes /admin/user/:id/edit_affiliate Ad" do
    {:get => "/admin/users/1/edit_affiliate"}.should route_to(
                                            :action => "edit_affiliate",
                                            :controller => "admin/users",
                                            :id => '1'
                                        )
  end

  it "routes /admin/user/:id/create_affiliate" do
    {:put => "/admin/users/1/create_affiliate"}.should route_to(
                                            :action => "create_affiliate",
                                            :controller => "admin/users",
                                            :id => '1'
                                        )
  end
  
end