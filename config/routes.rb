SampleTracker::Application.routes.draw do

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_for :users
  
  # NOTE: put this after the 'devise_for :users' line (adding a user index view to devise)
  resources :users, only: [:index, :show]
  resources :facilities, only: [:index, :show]
  resources :projects, only: [:index, :show]
  resources :analyses, only: [:index, :show]
  resources :storage_locations
  resources :containers
  resources :samples do
  end
  
  resources :sample_sets do
    member do
      post 'import_csv_samples'
      post 'import_csv_subsamples'
      get 'export_samples_csv'
      get 'export_subsamples_csv'
    end
    resources :samples, only: [:index, :new]
  end
  
  resources :samples do
    resources :samples, only: [:index, :new]
  end
  
  
  root  'static_pages#home'
  match '/register',    to: 'users#new',    via: 'get'
  match '/dashboard',   to: 'static_pages#dashboard',    via: 'get'
  match '/help',        to: 'static_pages#help',    via: 'get'
  match '/about',       to: 'static_pages#about',   via: 'get'
  match '/contact',     to: 'static_pages#contact', via: 'get'
                            
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
