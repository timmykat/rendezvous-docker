class Mailer < ApplicationMailer

  helper ApplicationHelper

  def send_to_us(name, email, message)
    @name = name
    @email = email
    @message = message
    recipients = Rails.configuration.rendezvous[Rails.env.to_sym][:inquiry_recipients]
    mail(to: recipients, subject: "New Rendezvous query from #{@name}")
  end
  
  def autoresponse(name, email, message)
    @name = name
    @email = email
    @message = message
    mail(to: @email, subject: 'Thanks for your inquiry about the Citroen Rendezvous')
  end
  
  def registration_acknowledgement(rendezvous_registration)
    @rr = rendezvous_registration
    registration_pdf = ::WickedPdf.new.pdf_from_url(rendezvous_registration_url(@rr, :protocol => (Rails.env.development? ? 'http' : 'https'), :print_token => Rails.configuration.rendezvous[:print_token]), :print_media_type => true, :ignore_load_errors => true)
    attachments["Rendezvous-2016-registration.pdf"] = registration_pdf
    mail(to: @rr.user.email, subject: "Thanks for registering for the 2016 Rendezvous!")
  end
  
  def registration_notification(rendezvous_registration)
    @rr = rendezvous_registration
    recipients = Rails.configuration.rendezvous[Rails.env.to_sym][:inquiry_recipients]
    mail(to: recipients, subject: "New Rendezvous registration from #{@rr.user.display_name}")
  end
end
