require 'logger'

class EmailLinksController < ApplicationController
  def new
  end

  def create

    user = User.find_by_email(params[:email])

    if user.nil?
      flash_alert = "I'm sorry, we couldn't find you in our system."
      redirect_to new_user_session_path 
    end

    @email_link = EmailLink.generate(params[:email])
    @recipient_name = user.full_name

    if @email_link
      flash_notice "Email sent! Please, check your inbox."
      redirect_to welcome_path
    else
      flash_alert = "I'm sorry, we couldn't find you in our system."
      redirect_to new_user_session_path 
    end
  end

  def validate
    email_link = EmailLink.where(token: params[:token]).where("expires_at > ?", DateTime.now).first

    unless email_link
      flash_alert "Invalid or expired token!"
      redirect_to new_email_link_path
    end

    flash_notice "You may or may not be logged in...."
    sign_in(email_link.user, scope: :user)
    redirect_to root_path
  end
end