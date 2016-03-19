class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  helper ApplicationHelper
  
  def require_admin
    if !current_user 
      flash[:alert] = "You must be logged in and a site admin to view that page (<a href='#{sign_up_or_in_path}'>sign in</a>)"
      redirect_to :root
      return
    elsif !(current_user.has_role? :admin)
      flash[:alert] = "You must be an admin to view that page."
      redirect_to :root
      return
    end
  end
  
  def after_sign_in_path_for(resource)
    if current_user.has_role? :admin    
      admin_index_path
    elsif current_user.rendezvous_registration.blank? || current_user.rendezvous_registration.status != 'complete'
      register_path
    else
      rendezvous_registration_path(current_user.rendezvous_registration)
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end  
end
