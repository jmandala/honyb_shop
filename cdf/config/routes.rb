Rails.application.routes.draw do

  namespace :admin do

    resources :products do
      member do
        get :biblio_info
        post :get_biblio_info
      end
    end

    namespace :fulfillment do
      match 'dashboard' => 'dashboard#index'
      
      namespace :system_check do
        match 'index'
        match 'order_check'
        match 'ftp_check'
        post :generate_test_orders        
      end
      
      resource :settings

      resources :po_files do
        collection do
          delete :purge
          post :submit_all
        end
        member do
          post :submit
        end
      end

      resources :poa_files do
        collection do
          delete :purge
          post :load_files

        end

        member do
          post :import
        end
      end

      resources :asn_files do
        collection do
          delete :purge
          post :load_files
        end

        member do
          post :import
        end
      end

      resources :cdf_invoice_files do
        collection do
          delete :purge
          post :load_files
        end

        member do
          post :import
        end
      end

      resources :ingram_stock_files do
        collection do
          delete :purge
          post :load_files

        end

        member do
          post :import
          post :download
        end
      end
    end

    resources :orders do
      collection do
        get :test_orders
      end
      
      member do
        get :fulfillment
        post :duplicate
      end
    end


  end


end
