Rails.application.routes.draw do

  root 'content_pages#index'

  # -- Users
  devise_for :users,
    controllers: {
      users: 'users',
      sessions: 'users/sessions',
      passwords: 'users/passwords',
      registrations: 'users/registrations'
    },
    path: ''
  
  resources :users 

  post :request_login_link, to: 'users#request_login_link'
  
  resources :users do
    get :welcome
    get :synchronize_mailchimp
  end

  devise_scope :user do
      get '/users/:id/sign_in_link', to: 'users/sessions#create_with_link'
  end

  # get '/users/sessions/sign_in_with_link/:id', to: 'users/sessions#create_with_link'
  # post '/new_login_link', to: 'users#new_login_link'
  # get '/welcome/:id', to: 'users#welcome'

  # get '/users/synchronize_mailchimp', to: 'users#synchronize_with_mailchimp'


  # -- Registrations
  # get '/event_registration',             to: 'registrations#new'
  namespace :event do
    resources :registrations  do 
      member do
        get :review
        get :payment
        patch :complete
        get :vehicles
      end
    end
    resources :registrations, except: [:index]
    get 'payment_token', to: 'registrations#get_payment_token'
    get '/welcome', to: 'registrations#welcome'
  end


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
