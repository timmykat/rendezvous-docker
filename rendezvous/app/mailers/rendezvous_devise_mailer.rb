class RendezvousDeviseMailer < Devise::Mailer   
  helper :application # gives access to all helpers defined within `application_helper`.
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
  
  layout 'rendezvous_mailer'

  default template_path: 'devise/mailer' # to make sure that your mailer uses the devise views

  def email_login_link(resource, raw_login_token, opts = {})
    @raw_login_token = raw_login_token
    devise_mail(resource, :email_login_link, opts)
  end
end