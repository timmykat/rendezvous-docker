class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :get_app_data
  before_action :flash_array

  CONFIG = Rails.configuration.rendezvous

  RECAPTCHA_MINIMUM_SCORE = 0.5

  # Need this for other gems that might set flash
  def flash_array

    # For testing
    # flash.keys << :note
    # flash[:note] = [
    #   "This is my flash message"
    # ]

    unless flash.keys.blank?
      flash.keys.each do |type|
        flash[type] = [ flash[type] ] if flash[type].is_a? String
      end
    end
  end

  def get_app_data
    @app_data =
      {
        event_fee: Config::SiteSetting.instance.registration_fee,
        marques: VehicleTaxonomy.get_marques,
        models: VehicleTaxonomy.get_citroen_models,
        provinces: CONFIG[:provinces],
        countries: CONFIG[:countries]
      }
  end

  def import_data(filename, klass_name)
    file_path = Rails.root.join('import_files', filename)
    klass = Object.const_get(klass_name)
    CSV.foreach(file_path, headers: true) do |row|
      klass.create!(row.to_hash)
    end
  end

  def get_objects(klass_name)
    klass = Object.const_get(klass_name)
    variable_name = klass_name.gsub("::", "").underscore
    if klass.has_attribute? :order
      objects = klass.sorted
    else
      objects = klass.all
    end
    if objects.empty?
      objects = [klass.new]
    end
    return objects
  end

  ## Recaptcha v3 -----------

  def verify_recaptcha?(token, recaptcha_action, email)
    
    # Check if user is whitelisted
    if !email.nil?
      user = User.find_by_email(email)
      if user && user.recaptcha_whitelisted?
        Rails.logger.warn "Skipping recaptcha for #{user.email}"
        return nil
      end
    end

    Rails.logger.debug "Recaptcha action: #{recaptcha_action}"
    # Continue normal recaptcha
    secret_key = CONFIG[:captcha][:secret_key]
    uri = URI.parse("https://www.google.com/recaptcha/api/siteverify?secret=#{secret_key}&response=#{token}")
    response = Net::HTTP.get_response(uri)
    json = JSON.parse(response.body)
    Rails.logger.debug "Recaptcha response: #{json}"
    if json['success'] && (json['score'] > RECAPTCHA_MINIMUM_SCORE) && (json['action'] == recaptcha_action)
      return nil
    else
      "We're sorry, you seem to be a bot"
    end
  end

  ## Recaptcha v3 -----------

  helper ApplicationHelper

  def require_admin
    return if current_user && (current_user.has_role? :admin)

    flash_alert("You must be a site admin to do that.")
    redirect_to :root
  end

  def after_sign_up_path_for(resource)
    user_path(resource)
  end

  def after_sign_in_path_for(resource)
    if !resource.current_registration
      event_welcome_path
    else
      landing_page_path
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

  # Create convenience methods for flash: flash_notice, flash_alert (anything will work)
  def method_missing(method_sym, *arguments, &block)
    if method_sym.to_s =~ /^flash_([a-z]+)(_(now))?$/
      type = $1.to_sym
      if $3 == 'now'
        flash.now[type] ||= []
        flash.now[type] << arguments.first
      else
        flash[type] ||= []
        flash[type] << arguments.first
      end
    else
      super
    end
  end

  def after_sending_reset_password_instructions_path_for(resource)
    sign_in_path
  end

  def respond_to? (method_sym, include_private = false)
    if method_sym.to_s =~ /^flash_([a-z]+)(_(now))?$/
      true
    else
      super
    end
  end

  def format_for_logging(hash)
    require 'pp'
    PP.pp(hash, '')
  end
end
