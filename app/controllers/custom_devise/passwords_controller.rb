class  CustomDevise::PasswordsController < Devise::PasswordsController
  skip_before_action :require_admin  

  # POST /resource/password
  def reset
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    yield resource if block_given?

    if successfully_sent?(resource)
      respond_with({}, :location => after_sending_reset_password_instructions_path_for(resource_name))
    else
      flash_alert("Sorry, that is not a valid email.")
      redirect_to root_path
      # respond_with(resource)
    end
  end
end
