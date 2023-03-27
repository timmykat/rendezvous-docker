class CustomDeviseMailer < Devise::Mailer

  def email_login_link(record, token, opts = {})
    @token = token
    devise_mail(record, :email_login_link, opts)
  end
  
end
