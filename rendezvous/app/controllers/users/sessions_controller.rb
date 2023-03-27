# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  def create_with_link
    self.resource = warden.authenticate!(auth_options)
    puts self.resource
    sign_in(resource_name, resource)
    yield resource if block_given?
    # respond_to do |format|
    #   set_flash_message!(:notice, :signed_in)
    #   format.html { redirect_to user_welcome_path(resource) }
    # end
    respond_with resource, location: after_sign_in_path_for(resource)
  end

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_in_with_link_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:id, :confirmation_token])
  end
end
