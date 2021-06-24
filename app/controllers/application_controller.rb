class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :get_app_data
  before_action :flash_array


  # Need this for other gems that might set flash
  def flash_array
    unless flash.keys.blank?
      flash.keys.each do |type|
        flash[type] = [ flash[type] ] if flash[type].is_a? String
      end
    end
  end

  def get_app_data
    @app_data =
      {
        :fees => Rails.configuration.rendezvous[:fees],
        :marques => Rails.configuration.rendezvous[:vehicle_marques],
        :models => Rails.configuration.rendezvous[:vehicle_models],
        :provinces => Rails.configuration.rendezvous[:provinces],
        :countries => Rails.configuration.rendezvous[:countries]
      }
  end

  helper ApplicationHelper

  def require_admin
    return if current_user && (current_user.has_role? :admin)

    flash_alert("You must be a site admin to do that.")
    redirect_to :root
  end

  def after_sign_up_path_for(resource)
    register_path
  end

  def after_sign_in_path_for(resource)
    session[:admin_user] = false
    @rendezvous_registration = current_user.rendezvous_registrations.current.first
    if current_user.has_role? :admin
      session[:admin_user] = true
      admin_index_path
    elsif @rendezvous_registration.blank? || @rendezvous_registration.status != 'complete'
      register_path
    else
      rendezvous_registration_path(@rendezvous_registration)
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

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
end
