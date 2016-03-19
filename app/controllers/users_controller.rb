class UsersController < ApplicationController

  def sign_up_or_in
  end
  
  def join_mailing_list
    gibbon = Gibbon::Request.new   # Automatically uses   MAILCHIMP_API_KEY environment variable
    gibbon.timeout = 10
    
    gibbon.lists(Rails.configuration.mailchimp.list_id).members.create(body: {email_address: params[:email], status: "subscribed"})
  end
  
  def find_by_email
    if User.find_by_email(params[:email])
      status = { :exists => true }
    else
      status = { :exists => false }
    end
    render :json => status  
  end
  
  def toggle_admin
    user = User.find(params[:user_id])
    if params[:admin]
      user.roles << :admin
    else
      user.roles.delete :admin
    end
    render :json => true
  end
end