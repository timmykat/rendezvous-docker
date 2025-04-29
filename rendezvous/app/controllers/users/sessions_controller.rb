# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  def request_login_link
    store_location_for(:user, request.referrer || request.fullpath)
    email = params[:email]
    failure_message = verify_recaptcha?(params[:recaptcha_token], 'get_login_link', email)
    if failure_message
      Rails.logger.warn "Login link: recaptcha failed for #{email}"
      redirect_to root_path, notice: failure_message
      return
    end

    @user = User.find_by_email(params[:email])

    flash_notice "Please check your inbox at #{params[:email]} for your sign-in link"
    
    if @user
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
    else
      redirect_to after_sign_in_path_for(resource)
    end
  end


  private
  
    def permitted_user_params
      user_params = ActionController::Parameters.new(user: params)
      user_params.require(:user).permit(
        [:login_token]
      )
    end
end
