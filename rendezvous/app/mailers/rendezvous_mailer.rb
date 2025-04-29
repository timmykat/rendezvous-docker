class RendezvousMailer < ApplicationMailer

  helper :application

  def no_email_found(email)
    Rails.logger.warn "No email found mailer: " + email
    @email = email
    mail to: @email, subject: 'Incorrect email for sign-in to the Citroen Rendezvous site'
  end

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
  
  def registration_confirmation(event_registration)
    @email = event_registration.user.email
    @event_registration = event_registration
    mail(to: @email, subject: "Thanks for registering for the #{Date.current.year} Rendezvous!")
  end

  def send_registration_open_notice(user)
      @name = user.first_name
      @email = user.email
      mail(to: @email, subject: "Rendezvous registration is open for #{Date.current.year}!")
  end
end
