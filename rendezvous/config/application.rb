require File.expand_path('../boot', __FILE__)

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "active_storage/engine"

# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Load dotenv
# if ['production', 'staging'].include? ENV['RAILS_ENV']
#   Dotenv::Rails.load
# end

module Rendezvous
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    #NOTVALID     config.active_record.raise_in_transactional_callbacks = true

    # Is this a docker environment (as opposed to EC2)

    config.load_defaults 7.0
    config.active_record.yaml_column_permitted_classes = [Date, Symbol]
    config.action_dispatch.default_headers = {
      'Cache-Control' => 'no-cache, no-store, must-revalidate',
      'Pragma' => 'no-cache',
      'Expires' => '0'
    }
    config.active_job.queue_adapter = :delayed_job

    config.active_storage.service = :local

    config.assets.paths << Rails.root.join("app", "assets", "images")
    
    config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += %W(#{config.root}/lib/rendezvous_square)
    config.autoload_paths += %W(#{config.root}/lib/vehicles)

    config.eager_load_paths += %W(#{config.root}/lib)
   
    config.rendezvous = YAML::load(ERB.new(File.read("#{Rails.root}/config/rendezvous.yml")).result, permitted_classes: [Date, Symbol]).deep_symbolize_keys
    config.mailer = YAML::load(ERB.new(File.read("#{Rails.root}/config/mailer.yml")).result, permitted_classes: [Date, Symbol]).deep_symbolize_keys
    config.recaptcha = YAML::load(ERB.new(File.read("#{Rails.root}/config/recaptcha.yml")).result, permitted_classes: [Date, Symbol]).deep_symbolize_keys
  end
end
