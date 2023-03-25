require 'logger'

require 'logger'

class EmailLinksController < ApplicationController
  def new

  end

  def create

    @email_link = EmailLink.generate(params[:email])


    if @email_link
      flash_notice "Email sent! Please, check your inbox."
      redirect_to welcome_path
    else
      flash_alert = "I'm sorry, we couldn't find you in our system."
      redirect_to user_sign_in_path 
    end
  end

  def validate
    email_link = EmailLink.where(token: params[:token]).where("expires_at > ?", DateTime.now).first

    unless email_link
      flash_alert = "Invalid or expired token!"
      redirect_to new_email_link_path
    end

    sign_in(email_link.user, scope: :user)
    redirect_to root_path
  end
end