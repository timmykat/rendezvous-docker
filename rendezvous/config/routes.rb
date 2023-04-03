Rails.application.routes.draw do
  get '/register',             to: 'registrations#new'
  get '/registration-welcome', to: 'registrations#welcome'

  resources :pictures, except: [:index]
  get '/gallery',                    to: 'pictures#index'
  get '/t-shirt-gallery',            to: 'pictures#t_shirt_gallery'
  get '/pictures_recreate_versions', to: 'pictures#recreate_versions'

  devise_for :users,
    :controllers => {
      :users => 'users',
      :passwords => 'custom_devise/passwords',
      :registrations => 'custom_devise/registrations'
    },
    :path => ''
  get '/users/synchronize_mailchimp', to: 'users#synchronize_with_mailchimp'
  resources :users

  resources :registrations do
    member do
      get :review
      get :payment
      patch :complete
      get :vehicles
    end
  end
  resources :registrations, :except => [:index]
  get 'payment_token', to: 'registrations#get_payment_token'


  # Admin routes
  get '/admin/toggle_user_session', to: 'admin#toggle_user_session'
  resources :admin, { :only => [:index] }
  namespace :admin do
    resources  :registrations, { :only => [ :show, :edit, :update ] }
    resources :transactions, { :only => [ :create ] }
    get 'registrations/:id/cancel', to: 'registrations#cancel', as: 'cancel_registration'
  end

  # Omniauth authentication
  # get '/auth/:provider/callback', to: 'sessions#create'


  root 'content_pages#index'
  get '/',                  to: 'content_pages#index'
  get '/faq',               to: 'content_pages#faq'
  get '/gallery',           to: 'content_pages#gallery'
  get '/history',           to: 'content_pages#history'
  get '/legal_information', to: 'content_pages#legal_information'
  get '/schedule',          to: 'content_pages#schedule'
  get '/vendors',           to: 'content_pages#vendors'

  # User management
  get '/user_sign_up', to: 'users#sign_up'
  get '/user_sign_in', to: 'users#sign_in'

  # Picture upload
  get '/my-pictures', to: 'pictures#my_pictures'
  post '/pictures/upload(.:format)', to:'pictures#upload'

  # Contact form
  post '/contact-us', to:'content_pages#contact_us'

  # Send email
  get '/send_email', to: 'registrations#send_email'

  # AJAX routes
  get '/ajax/picture/delete/:id', to: 'pictures#ajax_delete'
  get '/ajax/find_user_by_email', to: 'users#find_by_email'
  get '/ajax/toggle_admin',       to: 'users#toggle_admin'
  get '/ajax/toggle_tester',      to: 'users#toggle_tester'
  get '/ajax/delete_users',       to: 'users#delete_users'

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
