Rails.application.routes.draw do
  filter :affiliate_key_filter
  
  namespace :admin do

    resources :users do
      member do
        get 'edit_affiliate'
        put 'update_affiliate'
      end
    end
  end
  
end
