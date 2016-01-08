class RegistrationsController < Devise::RegistrationsController
  def create
    if session[:omniauth] == nil #OmniAuth
      if verify_recaptcha
        super
        session[:omniauth] = nil unless @user.new_record? #OmniAuth
      else
        build_resource
        clean_up_passwords(resource)
        flash[:alert] = "There was an error with the recaptcha code below. Please re-enter the code."
        #use render :new for 2.x version of devise
        render_with_scope :new 
      end
    else
      super
      session[:omniauth] = nil unless @user.new_record? #OmniAuth
    end
end
end