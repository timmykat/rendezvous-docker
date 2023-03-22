class EmailLinkMailer < ApplicationMailer
  def sign_in_mail(email_link)
    @token = email_link.token
    @user = email_link.user

    mail to: @user.email, subject: "Your citroenrendezvous.org login link 🚀"
  end
end