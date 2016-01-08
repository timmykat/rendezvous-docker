class UsersController < ApplicationController
  def sign_up_or_in
  end
  
  def join_mailing_list
    gibbon = Gibbon::Request.new   # Automatically uses   MAILCHIMP_API_KEY environment variable
    gibbon.timeout = 10
    
    gibbon.lists(Rails.configuration.mailchimp.list_id).members.create(body: {email_address: params[:email], status: "subscribed"})
  end
end