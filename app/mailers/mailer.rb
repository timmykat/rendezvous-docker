class Mailer < ApplicationMailer

  helper ApplicationHelper

  def send_to_us(name, email, message)
    @name = name
    @email = email
    @message = message
    recipients = Rails.configuration.rendezvous[Rails.env.to_sym][:inquiry_recipients]
    mail(to: recipients, from: @email, subject: "New Rendezvous query from #{@name}")
  end
  
  def autoresponse(name, email, message)
    @name = name
    @email = email
    @message = message
    mail(to: @email, subject: 'Thanks for your inquiry about the Citroen Rendezvous')
  end
  
  def registration_confirmation(rendezvous_registration)
    @rendezvous_registration = rendezvous_registration
#     registration_pdf = ::WickedPdf.new.pdf_from_url(rendezvous_registration_url(@rr, :protocol => (Rails.env.development? ? 'http' : 'https'), :print_token => Rails.configuration.rendezvous[:print_token]), :print_media_type => true, :ignore_load_errors => true)
#     filename = "#{@rendezvous_registration.invoice_number}.pdf"
#     attachments[filename] =File.read(Rails.root.join('public','registrations', filename))
    mail(to: @rendezvous_registration.user.email, subject: "Thanks for registering for the #{Time.now.year} Rendezvous!")
  end
  
  def registration_notification(rendezvous_registration)
    @rendezvous_registration = rendezvous_registration
    recipients = Rails.configuration.rendezvous[Rails.env.to_sym][:inquiry_recipients]
    mail(to: recipients, subject: "New Rendezvous registration from #{@rendezvous_registration.user.display_name}")
  end  
end
