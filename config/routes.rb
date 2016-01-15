Rails.application.routes.draw do
  resources :pictures
  devise_for :users, :controllers => 
    { :users => 'users', 
      :omniauth_callbacks => "users/omniauth_callbacks" 
    }
  resources :users
  
  # Omniauth authentication
  get '/auth/:provider/callback', to: 'sessions#create'
  
  root 'main_pages#index'
  get '/', to: 'main_pages#index'
  get '/vendors', to: 'main_pages#vendors'
  get '/history', to: 'main_pages#history'
  
  # User management
  get '/sign_up_or_in', to: 'users#sign_up_or_in'
  
  # Picture upload
  get '/my-pictures', to: 'pictures#my_pictures'
  post '/pictures/upload', to:'pictures#upload'
  
  # Contact form
  post '/contact-us', to:'main_pages#contact_us'
  

  # AJAX routes
  get '/ajax/picture/delete/:id', to: 'pictures#ajax_delete'

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
