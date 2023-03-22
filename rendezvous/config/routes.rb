Rails.application.routes.draw do

  root 'content_pages#index'

  get '/welcome', to: 'users#welcome'

  # -- Users
  devise_for :users,
    controllers: {
      users: 'users',
      passwords: 'custom_devise/passwords',
      registrations: 'custom_devise/registrations'
    },
    path: ''
  get '/users/synchronize_mailchimp', to: 'users#synchronize_with_mailchimp'
  resources :users

  get '/user_sign_up', to: 'users#sign_up'
  get '/user_sign_in', to: 'users#sign_in'  

  get '/email_links/new', as: :new_email_link
  post '/email_links/create', as: :email_link
  get '/email_links/validate', as: :email_link_validate

  # -- Registrations
  get '/register',             to: 'registrations#new'
  get '/registration-welcome', to: 'registrations#welcome'

  resources :registrations do
    member do
      get :review
      get :payment
      patch :complete
      get :vehicles
    end
  end
  resources :registrations, except: [:index]
  get 'payment_token', to: 'registrations#get_payment_token'


  # Admin routes
  get '/admin/toggle_user_session', to: 'admin#toggle_user_session'
  resources :admin, { only: [:index] }
  namespace :admin do
    resources  :registrations, { only: [ :show, :edit, :update ] }
    resources :transactions, { only: [ :create ] }
    get 'registrations/:id/cancel', to: 'registrations#cancel', as: 'cancel_registration'
  end

  # -- Content
  get '/',                  to: 'content_pages#index'
  get '/faq',               to: 'content_pages#faq'
  get '/gallery',           to: 'content_pages#gallery'
  get '/history',           to: 'content_pages#history'
  get '/legal_information', to: 'content_pages#legal_information'
  get '/schedule',          to: 'content_pages#schedule'
  get '/vendors',           to: 'content_pages#vendors'

  resources :pictures, except: [:index]
  get '/gallery',                    to: 'pictures#index'
  get '/t-shirt-gallery',            to: 'pictures#t_shirt_gallery'
  get '/pictures_recreate_versions', to: 'pictures#recreate_versions'

  # -- Picture upload
  get '/my-pictures', to: 'pictures#my_pictures'
  post '/pictures/upload(.:format)', to:'pictures#upload'


  # -- AJAX routes
  get '/ajax/picture/delete/:id', to: 'pictures#ajax_delete'
  get '/ajax/find_user_by_email', to: 'users#find_by_email'
  get '/ajax/toggle_admin',       to: 'users#toggle_admin'
  get '/ajax/toggle_tester',      to: 'users#toggle_tester'
  get '/ajax/delete_users',       to: 'users#delete_users'

end
