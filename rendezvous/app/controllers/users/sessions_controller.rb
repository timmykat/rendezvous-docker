# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  def request_login_link
    @user = User.find_by_email(params[:email])

    flash_notice 'Please check your email inbox'
    
    if @user
      Rails.logger.debug "Sending the link for a user"
      @user.send_login_link
    else
      Rails.logger.debug "This email is not valid " + params[:email]
      RendezvousMailer.no_email_found(params[:email]).deliver
    end

    redirect_to root_path
  end

  def create_with_link
    self.resource = warden.authenticate!
    set_flash_message!(:notice, :signed_in)
    Rails.logger.debug resource_name
    sign_in(resource_name, resource)
    yield resource if block_given?
    Rails.logger.debug 'Redirecting to new event registration page'
    redirect_to new_event_registration_path
    # respond_with resource, { location: after_sign_in_path_for(resource) }
  end


  private
  
    def permitted_user_params
      user_params = ActionController::Parameters.new(user: params)
      user_params.require(:user).permit(
        [:login_token]
      )
    end
end
