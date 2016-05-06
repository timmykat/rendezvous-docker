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
    @rendezvous_registration = rendezvous_registration
    filename = "#{@rendezvous_registration.invoice_number}.pdf"
    attachments[filename] = File.read(Rails.root.join('public','registrations', filename))
    mail(to: @rendezvous_registration.user.email, subject: "Thanks for registering for the 2016 Rendezvous!")
  end
  
  def registration_notification(rendezvous_registration)
    @rendezvous_registration = rendezvous_registration
    recipients = Rails.configuration.rendezvous[Rails.env.to_sym][:inquiry_recipients]
    mail(to: recipients, subject: "New Rendezvous registration from #{@rendezvous_registration.user.display_name}")
  end
  
  def registration_update(type_and_method, rendezvous_registration)
    @rendezvous_registration = rendezvous_registration

    case type
    when 'cancellation - credit card'
    when 'cancellation - check'
    when 'update - credit card'
    when 'update - check'
    end
    
    mail(to: @rendezvous_registration.user.email, subject: "Your registration #{/(update|cancellation)/.match('cancellation - credit card').to_s} for the 2016 Rendezvous")
  end
end
