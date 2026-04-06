class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :flash_array
  before_action :get_app_data
  before_action :update_active_user
  before_action :ensure_delete_method, only: :destroy

  helper_method :current_time
  helper_method :debug_date
  helper_method :event_fees
  helper_method :event_fees_for_period
  helper_method :fee_period
  helper_method :get_reg_id
  helper_method :is_debug_date
  helper_method :registration_status
  helper_method :sunday_lunch_max
  helper_method :lake_cruise_max
  helper_method :lake_cruise_price
  helper_method :lake_cruise_closed
  helper_method :lake_cruise_venue_link
  helper_method :written_reg_form_link
  helper_method :login_on
  helper_method :active_users

  GEO_CONFIG = Rails.configuration.geodata

  ACTIVITY_WINDOW = 15.minutes

  layout :select_layout

  def select_layout
    ['manage'].include?(action_name) ? "admin_layout" : "application"
  end

  def ensure_delete_method
    return unless action_name == "destroy"
    return if request.delete?

    Rails.logger.error("🚨 Non-DELETE request hit destroy: #{request.method} #{request.fullpath}")
    head :method_not_allowed
  end

  def active_users
    return unless current_user&.admin?

    n = User.where('last_active > ?', ACTIVITY_WINDOW.ago).count
    if n == 0
      "There are no other active users."
    elsif n == 1
      "There is 1 active user."
    else
      "There are #{n} active users."
    end
  end

  def render(*args)
    Rails.logger.debug "Calling render from: #{caller(1..5).join("\n")}"
    super(*args) # Call the original render method
  end

  def registration_status
    current_user&.current_registration.present? ? current_user.current_registration.status.titlecase : 'Not Registered'
  end

  def is_debug_date
    Config::SiteSetting.instance.debug_dates
  end

  def login_on
    Config::SiteSetting.instance.login_on
  end

  def debug_date
    Config::SiteSetting.instance.debug_test_date.to_time.strftime("%B %d")
  end

  def current_time
    if is_debug_date
      debug_date
    else
      Time.current
    end
  end

  def event_fees_for_period
    Rails.configuration.pricing[:fees][fee_period]
  end

  def fee_period
    (current_time <= Rails.configuration.pricing[:fees][:early][:end_date].to_time) ? :early : :late
  end

  def written_reg_form_link
    "/#{Date.current.year}-Rendezvous-registration-#{fee_period}.pdf"
  end

  # This currently has an absolute max in the DB of 8
  def sunday_lunch_max
    Rails.configuration.registration[:sunday_lunch_max]
  end

  def lake_cruise_max
    Rails.configuration.registration[:lake_cruise_max]
  end

  def lake_cruise_price
    Rails.configuration.pricing[:fees][:lake_cruise][:price]
  end

  def lake_cruise_closed
    current_time > Rails.configuration.registration[:lake_cruise_close_date].to_time
  end

  def lake_cruise_venue_link
    venue_id = Venue.where("name LIKE ?", "%Cruise%").pick(:id)
    venue_path(venue_id) unless venue_id.nil?
  end

  # Need this for other gems that might set flash
  def flash_array

    # For testing
    # flash.keys << :note
    # flash[:note] = [
    #   "This is my flash message"
    # ]

    unless flash.keys.blank?
      flash.keys.each do |type|
        flash[type] = [flash[type]] if flash[type].is_a? String
      end
    end
  end

  def get_app_data
    @app_data =
      {
        fees: event_fees_for_period,
        marques: Vehicles::VehicleTaxonomy.get_marques,
        models: Vehicles::VehicleTaxonomy.get_citroen_models,
        provinces: GEO_CONFIG[:provinces],
        countries: GEO_CONFIG[:countries]
      }
  end

  def update_active_user
    return if current_user.nil? ||
           current_user.last_active.nil? ||
           current_user.last_active < ACTIVITY_WINDOW.ago

    current_user.update_column(:last_active, Time.current)
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
  RECAPTCHA_MINIMUM_SCORE = 0.5

  def verify_recaptcha?(token, recaptcha_action, email)

    if (!Rails.env.production?)
      Rails.logger.debug "Skipping recaptcha in non-production environment"
      return nil
    end

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
    secret_key = Rails.configuration.recaptcha[:secret_key]
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
    return true if current_user and (current_user.has_role? :admin)

    flash_alert("You must be a site admin to do that.")
    redirect_to :root
  end

  def after_sign_up_path_for(resource)
    user_path(resource)
  end

  def after_sign_in_path_for(resource)
    if resource.has_role? :admin
      admin_dashboard_path
    elsif !resource.current_registration
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
