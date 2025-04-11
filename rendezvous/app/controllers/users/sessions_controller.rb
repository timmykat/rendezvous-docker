# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  def request_login_link

    unless verify_recaptcha?(recaptcha_param, 'get_login_link')
      Rails.logger.warn "Login link: recaptcha failed for email #{params[:email]}"
      redirect_to root_path, notice: 'You have failed reCAPTCHA verification for login'
      return
    end

    @user = User.find_by_email(params[:email])

    flash_notice "Please check your inbox at #{params[:email]} for your sign-in link"
    
    if @user
      Rails.logger.debug "Sending the link for a user"
      @user.send_login_link
    end

    redirect_to root_path
  end

  def create_with_link
    self.resource = warden.authenticate!
    set_flash_message!(:notice, :signed_in)
    Rails.logger.debug resource_name
    sign_in(resource_name, resource)
    yield resource if block_given?
    if !resource
      flash_alert 'We\re sorry, we were unable to authenticate that email address, or your token is expired.'
      redirect_to new_session_path(resource_name)
    elsif resource.admin?
      redirect_to admin_dashboard_path
    else
      redirect_to new_event_registration_path
    end
  end


  private
  
    def permitted_user_params
      user_params = ActionController::Parameters.new(user: params)
      user_params.require(:user).permit(
        [:login_token]
      )
    end

    def recaptcha_param
      params.require(:recaptcha_token)
    end
end
