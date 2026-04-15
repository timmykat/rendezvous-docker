require "sidekiq/web"

Rails.application.routes.draw do

  # health check
  get "/up", to: "rails/health#show"

  # sidekiq
  authenticate :user, lambda { |user| user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

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
    get 'u/:login_token', to: 'users/sessions#create_with_link', as: :sign_in_with_link
  end

  resources :users
  get 'edit_user_vehicles/:id', to: 'users#edit_user_vehicles', as: :edit_user_vehicles
  get :new_user_by_admin, to: 'users#new_user_by_admin'
  post :create_user_by_admin, to: 'users#create_user_by_admin'

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
  get '/schedule_summary', to: 'scheduled_events#summary', as: :schedule_summary

  get 'venues/import', to: 'venues#import'
  get 'venues/manage', to: 'venues#manage'
  delete 'venues/destroy_all', to: 'venues#destroy_all', as: :destroy_all_venues
  resources :venues, { except: [:index] }

  resources :vehicles
  get 'on_site_vehicles/for_sale', to: 'vehicles#for_sale', as: :vehicles_for_sale

  resources :event_hotels, { except: [:new, :index, :show] }

  # -- Registrations
  # get '/event_registration',             to: 'registrations#new'
  namespace :event do
    resources :modifications, only: [:show] do
      member do
        patch :apply
        post :send_payment_link
      end
    end
    resources :registrations do
      collection do
        get :new_by_admin
        post :create_by_admin
      end
      member do
        get :cancel
        get :complete_after_online_payment
        get :edit_sunday_lunch
        get :modify
        get :modify_by_admin
        get :payment
        get :review
        get :send_confirmation
        get :send_to_square
        get :special_events
        get :vehicles
        patch :complete
        patch :update_by_admin
        patch :update_special_events
        patch :update_sunday_lunch
        post :save_modification
        post :payment_request
      end
    end
    get '/welcome', to: 'registrations#welcome'
  end

  namespace :email do
    get :create_message
    post :send_message
  end

  namespace :admin do
    get 'dedupe', to: 'admin#dedupe'
    get 'dashboard', to: 'admin#dashboard'
    get 'manage', to: 'admin#manage'
    get 'download_csv', to: 'admin#download_csv', defaults: { format: 'csv' }
    get 'graphs', to: 'admin#registration_graphs'
    get 'cleanup', to: 'users#cleanup'
    post 'cleanup', to: 'users#cleanup'
    get 'print', to: 'admin#print'
    get 'manage_qr_codes', to: 'admin#manage_qr_codes'
    get 'generate_qr_codes', to: 'admin#generate_qr_codes'
    get 'peoples_choice_results', to: 'admin#peoples_choice_results'
    get 'ballots/clear', to: 'admin#clear_ballots'
    get 'update_user_vehicles/:id', to: 'admin#update_user_vehicles'
  end

  namespace :voting do
    get '/ballot', to: 'ballots#ballot', as: :get_voting_ballot
    get '/hand_ballot', to: 'ballots#hand_ballot'
    post '/hand_count', to: 'ballots#hand_count'
    post '/ballots/vote', to: 'ballots#vote', as: :vote
    delete '/ballots/vehicle/delete', to: 'ballots#delete_selection', as: :delete_vehicle_selection
  end
  get '/_ajax/voting/vehicle/:code', to: 'vehicles#ajax_info'

  resources :donations, { only: [:new, :create, :index] }
  get '/donations/:id/thank_you', to: 'donations#thank_you', as: :thank_you

  # -- Content
  get '/faq', to: 'main_pages#faq'
  get '/history', to: 'main_pages#history'
  get '/volunteering', to: 'main_pages#volunteering'
  get '/landing_page', to: 'main_pages#landing_page'
  get '/legal_information', to: 'main_pages#legal_information'
  get '/schedule', to: 'main_pages#schedule'

  resources :pictures, except: [:index]
  get '/gallery', to: 'pictures#index'
  get '/t-shirt-gallery', to: 'pictures#t_shirt_gallery'
  get '/pictures_recreate_versions', to: 'pictures#recreate_versions'

  # -- Picture upload
  get '/my-pictures', to: 'pictures#my_pictures'
  post '/pictures/upload(.:format)', to: 'pictures#upload'

  # -- AJAX routes
  get '/ajax/find_user_by_email', to: 'users#find_by_email'
  delete '/ajax/delete_users', to: 'users#delete_users'
  get '/ajax/user/autocomplete', to: 'users#autocomplete'
  get '/ajax/code/search', to: 'qr_codes#autocomplete'

  namespace :event do
    patch '/ajax/update_fees/:id', to: 'registrations#update_fees'
    get '/ajax/update_paid_method/:id', to: 'registrations#update_paid_method'
  end

  get '/ajax/toggle/role/:id', to: 'users#toggle_role', as: :ajax_toggle_role
  get '/ajax/toggle/whitelist/:id', to: 'users#toggle_whitelist', as: :ajax_toggle_whitelist
  namespace :square do
    post 'webhooks/receive', to: 'webhooks#receive'
  end
end
