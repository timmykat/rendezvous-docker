class RendezvousDeviseMailer < Devise::Mailer   
  helper :application # gives access to all helpers defined within `application_helper`.
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
  
  layout 'rendezvous_mailer'

  default template_path: 'devise/mailer' # to make sure that your mailer uses the devise views

  def email_login_link(resource, login_token, opts = {})
    Rails.logger.debug("Resource: " + resource.email)
    @login_token = login_token
    opts[:subject] = 'Login link for CitroenRendezvous.org'
    devise_mail(resource, :email_login_link, opts)
  end
end