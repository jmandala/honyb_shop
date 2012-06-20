Rails.application.routes.draw do
  filter :affiliate_key_filter

  namespace :admin do
    namespace :reports do
      collection do
        get :sales_detail
      end

    end
  end
end
