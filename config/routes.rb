Rails.application.routes.draw do
  get '/register', to: 'rendezvous_registrations#new'
  
  resources :pictures
  devise_for :users, 
    :controllers => { 
      :users => 'users',
      :passwords => 'custom_devise/passwords',
      :registrations => 'custom_devise/registrations'
    },
    :path => ''
  get '/users/synchronize_mailchimp', to: 'users#synchronize_with_mailchimp'
  resources :users
  
  resources :rendezvous_registrations do
    member do
      get :review
      get :payment
      patch :complete
      get :update_completed
    end
  end
  resources :rendezvous_registrations, :except => [:index]
  
  get '/admin/toggle_user_session', to: 'admin#toggle_user_session'
  resources :admin, { :only => [:index] }
  
  # Omniauth authentication
  get '/auth/:provider/callback', to: 'sessions#create'
  
  
  root 'content_pages#index'
  get '/',                  to: 'content_pages#index'
  get '/faq',               to: 'content_pages#faq'
  get '/history',           to: 'content_pages#history'
  get '/legal_information', to: 'content_pages#legal_information'
  get '/schedule',          to: 'content_pages#schedule'
  get '/vendors',           to: 'content_pages#vendors'
  
  # User management
  get '/sign_up_or_in', to: 'users#sign_up_or_in'
  
  # Picture upload
  get '/my-pictures', to: 'pictures#my_pictures'
  post '/pictures/upload', to:'pictures#upload'
  
  # Contact form
  post '/contact-us', to:'content_pages#contact_us'
  

  # AJAX routes
  get '/ajax/picture/delete/:id', to: 'pictures#ajax_delete'
  get '/ajax/find_user_by_email', to: 'users#find_by_email'
  get '/ajax/toggle_admin',       to: 'users#toggle_admin'
  
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
