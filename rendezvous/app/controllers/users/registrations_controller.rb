require 'securerandom'

class Users::RegistrationsController < Devise::RegistrationsController 
  # Auto-generate a password
  PASSWORD_LENGTH = 20

  include ApplicationHelper

  def new
    @password = valid_password
    @email = params[:email]
    super
  end

  def create

    unless verify_recaptcha?(params[:recaptcha_token], 'register_user')
      Rails.logger.warn "Login link: recaptcha failed for email #{params[:email]}"
      redirect_to root_path, notice: 'You have failed reCAPTCHA verification for user registration'
      return
    end

    # Check for existing user
    Rails.logger.debug "Submitted email: #{params[:user][:email]}"
    if User.find_by_email(params[:user][:email])
      redirect_to new_user_session_path, notice: 'That email address is already in use.'
      return
    end

    build_resource(sign_up_params)

    resource.save

    yield resource if block_given?
    if resource.persisted?
      Rails.logger.debug "Resource persisted"
      if resource.active_for_authentication?
        flash_notice "Congratulations, you've successfully signed up! Check your email inbox for a link to log in."
        resource.send_login_link
        redirect_to root_path
      else
        Rails.logger.debug "Resource inactive"
        flash_notice :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        redirect_to root_path
        # respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      Rails.logger.debug "Responding with resource"
      clean_up_passwords resource
      set_minimum_password_length
      super.respond_with_resource
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