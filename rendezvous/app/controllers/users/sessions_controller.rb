# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  def create_with_link
    self.resource = warden.authenticate!
    set_flash_message!(:notice, :signed_in)
    Rails.logger.debug resource_name
    sign_in(resource_name, resource)
    yield resource if block_given?
    Rails.logger.debug 'Responding with resource to ' + after_sign_in_path_for(resource)
    respond_with resource, { location: after_sign_in_path_for(resource) }
  end


  private
  
    def permitted_user_params
      user_params = ActionController::Parameters.new(user: params)
      user_params.require(:user).permit(
        [:login_token]
      )
    end
end
