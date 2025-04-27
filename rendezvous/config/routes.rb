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
    get 'u/:login_token',       to: 'users/sessions#create_with_link', as: :sign_in_with_link
  end

  resources :users

  resources :annual_questions, { only: [:create, :update, :destroy] }

  # Site settings
  namespace :config do
    get 'site_settings/get', to: 'site_settings#get'
    post 'site_settings/update', to: 'site_settings#update'
  end

  # CMS content
  get 'vendors/import', to: 'vendors#import'
  get 'vendors/manage', to: 'vendors#manage'
  delete 'vendors/destroy_all', to: 'vendors#destroy_all', as: :destroy_all_vendors
  resources :vendors, { except: [:show] }

  get 'keyed_contents/import', to: 'keyed_contents#import'
  get 'keyed_contents/manage', to: 'keyed_contents#manage'
  delete 'keyed_contents/destroy_all', to: 'keyed_contents#destroy_all', as: :destroy_all_keyed_contents
  resources :keyed_contents, { except: [:show] }

  get 'faqs/import', to: 'faqs#import'
  get 'faqs/manage', to: 'faqs#manage'
  delete 'faqs/destroy_all', to: 'faqs#destroy_all', as: :destroy_all_faqs
  resources :faqs, { except: [:show] }

  get 'scheduled_events/import', to: 'scheduled_events#import'
  get 'scheduled_events/manage', to: 'scheduled_events#manage'
  delete 'scheduled_events/destroy_all', to: 'scheduled_events#destroy_all', as: :destroy_all_scheduled_events
  resources :scheduled_events, { except: [:show] }

  get 'venues/import', to: 'venues#import'
  get 'venues/manage', to: 'venues#manage'
  delete 'venues/destroy_all', to: 'venues#destroy_all', as: :destroy_all_venues
  resources :venues, { except: [:index, :show] }

  get 'vehicles/for_sale', to: 'vehicles#for_sale'

  resources :event_hotels, { except: [:new, :index, :show] }

  # -- Registrations
  # get '/event_registration',             to: 'registrations#new'
  namespace :event do
    resources :registrations  do 
      member do
        get :review
        get :payment
        patch :complete
        get :complete_after_online_payment
        get :send_to_square
        get :vehicles
        get :send_email_confirmation
        get :update_vehicles
        patch :save_updated_vehicles
      end
    end
    resources :registrations, except: [:index]
    get '/welcome', to: 'registrations#welcome'
  end


  get '/admin/dedupe',            to: 'admin#dedupe'
  get '/admin/dashboard',         to: 'admin#dashboard'
  get '/admin/download_csv',      to: 'admin#download_csv', defaults: { format: 'csv' }
  get '/admin/graphs',            to: 'admin#registration_graphs'
  get '/admin/cleanup',           to: 'users#cleanup'
  post '/admin/cleanup',          to: 'users#cleanup'

  namespace :event do
  #     resources  :registrations, { only: [ :create, :show, :edit, :update ] }
  #     get 'registrations/new/user/:id', to: 'registrations#new'
  #     get 'registrations/new/withemail', to: 'registrations#new_with_email'
  #     post 'registrations/create/withemail', to: 'registrations#create_with_email'
    get 'registrations/:id/cancel', to: 'registrations#cancel', as: 'cancel_registration'
    get 'registrations/:id/delete', to: 'registrations#delete', as: 'delete_registration'
  #     get 'registrations/:id/send_confirmation_email', to: 'registrations#send_confirmation_email'
  end

  get '/voting/ballot(/:id)',                   to: 'voting/ballots#ballot', as: :get_voting_ballot
  post '/turbo/voting/ballots/vote',            to: 'voting/ballots#vote', as: :turbo_vote
  post '/turbo/voting/ballots/vehicle/delete',  to: 'voting/ballots#delete_selection', as: :turbo_delete_vehicle
  get '/_ajax/voting/vehicle/:code',            to: 'vehicles#ajax_info'


  resources :donations, { only: [ :new, :create, :index ] }
  get '/donations/:id/thank_you', to: 'donations#thank_you', as: :thank_you

  # -- Content
  get '/',                          to: 'main_pages#index'
  get '/faq',                       to: 'main_pages#faq'
  get '/history',                   to: 'main_pages#history'
  get '/volunteering',              to: 'main_pages#volunteering'
  get '/landing_page',  to: 'main_pages#landing_page'
  get '/legal_information',         to: 'main_pages#legal_information'
  get '/schedule',                  to: 'main_pages#schedule'

  resources :pictures, except: [:index]
  get '/gallery',                    to: 'pictures#index'
  get '/t-shirt-gallery',            to: 'pictures#t_shirt_gallery'
  get '/pictures_recreate_versions', to: 'pictures#recreate_versions'

  # -- Picture upload
  get '/my-pictures', to: 'pictures#my_pictures'
  post '/pictures/upload(.:format)', to:'pictures#upload'

  # -- AJAX routes
  get '/ajax/find_user_by_email',         to: 'users#find_by_email'
  get '/ajax/delete_users',               to: 'users#delete_users'
  get '/ajax/user/autocomplete',          to: 'users#autocomplete'

  namespace :event do
    post '/ajax/update_fees',               to: 'registrations#update_fees'
    get '/ajax/update_paid_method',         to: 'registrations#update_paid_method'
  end

  get '/ajax/toggle/role/:id',               to: 'users#toggle_role',      as: :ajax_toggle_role
  get '/ajax/toggle/whitelist/:id',          to: 'users#toggle_whitelist', as: :ajax_toggle_whitelist
end
