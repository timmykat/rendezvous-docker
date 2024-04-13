Rails.application.routes.draw do

  root 'main_pages#index'

  # -- Users
  

  devise_for :users,
    controllers: {
      users: 'users',
      sessions: 'users/sessions',
      passwords: 'users/passwords',
      registrations: 'users/registrations'
    },
    path: '',
    path_names: {
      sessions: '',
      registration: 'site'
    }

  devise_scope :user do
    post :request_login_link, to: 'users/sessions#request_login_link'
    get :sign_in_with_link, to: 'users/sessions#create_with_link'
    # post :sign_up, to: 'users/registrations#create'
  end

  resources :users

  # -- Registrations
  # get '/event_registration',             to: 'registrations#new'
  namespace :event do
    resources :registrations  do 
      member do
        get :review
        get :payment
        patch :complete
        get :vehicles
        get :send_email_confirmation
      end
    end
    resources :registrations, except: [:index]
    get 'payment_token', to: 'registrations#get_payment_token'
    get '/welcome', to: 'registrations#welcome'
  end


  # Admin routes
  get '/admin/toggle_user_session', to: 'admin#toggle_user_session'
  get '/admin/labels', to: 'admin#make_labels'
  
  resources :admin, { only: [:index] }
  namespace :admin do
    namespace :event do
      resources  :registrations, { only: [ :show, :edit, :update ] }
      get 'registrations/new/user/:id', to: 'registrations#new_with_user'
      get 'registrations/:id/cancel', to: 'registrations#cancel', as: 'cancel_registration'
      get 'registrations/:id/send_confirmation_email', to: 'registrations#send_confirmation_email'
    end
    resources :transactions, { only: [ :create ] }
  end

  # -- Content
  get '/',                  to: 'main_pages#index'
  get '/faq',               to: 'main_pages#faq'
  get '/history',           to: 'main_pages#history'
  get '/legal_information', to: 'main_pages#legal_information'
  get '/schedule',          to: 'main_pages#schedule'
  get '/vendors',           to: 'main_pages#vendors'

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
