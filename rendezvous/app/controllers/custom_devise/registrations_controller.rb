class CustomDevise::RegistrationsController < Devise::RegistrationsController 

  def create
    build_resource(sign_up_params)

    resource.save
    
    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        flash_notice "Congratulations, you've successfully signed up!"
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        flash_notice :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      render template: 'users/sign_in'
    end
  end

  private
    def sign_up_params
      params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
    end

    def account_update_params
      params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :current_password)
    end
end