require 'securerandom'

class Users::RegistrationsController < Devise::RegistrationsController 
  # Auto-generate a password
  PASSWORD_LENGTH = 20
  def new
    @password = valid_password
    @email = params[:email]
    super
  end

  def create
    build_resource(sign_up_params)

    resource.save

    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        flash_notice "Congratulations, you've successfully signed up! Check your email inbox for a link to log in."
        resource.send_login_link
        redirect_to root_path
      else
        flash_notice :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        redirect_to root_path
        # respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with_resource
    end
  end

  private
    def valid_password
      pw = ''
      while !( pw.match(/[a-z]/) && pw.match(/[A-Z]/) && pw.match(/[0-9]/) )
        pw = SecureRandom.alphanumeric( PASSWORD_LENGTH )
      end
      pw
    end

    def sign_up_params
      params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
    end

    def account_update_params
      params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :current_password)
    end
end