class RendezvousMailer < ApplicationMailer

  helper :application

  def no_email_found(email)
    Rails.logger.debug "No email found mailer: " + email
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
  
  def registration_confirmation(registration)
    Rails.logger.info "Sending registration confirmation email"
    @event_registration = registration
#     registration_pdf = ::WickedPdf.new.pdf_from_url(registration_url(@rr, protocol: (Rails.env.development? ? 'http' : 'https'), print_token: Rails.configuration.rendezvous[:print_token]), print_media_type: true, ignore_load_errors: true)
#     filename = "#{@event_registration.invoice_number}.pdf"
#     attachments[filename] =File.read(Rails.root.join('public','registrations', filename))
    mail(to: @event_registration.user.email, subject: "Thanks for registering for the #{Time.now.year} Rendezvous!")
  end
  
  def registration_notification(registration)
    @event_registration = registration
    recipients = Rails.configuration.rendezvous[Rails.env.to_sym][:inquiry_recipients]
    mail(to: recipients, subject: "New Rendezvous registration from #{@event_registration.user.display_name}")
  end  

  def send_registration_open_notice(user)
      @name = user.first_name
      @email = user.email
      mail(to: @email, subject: "Rendezvous registration is open for #{Time.now.year}!")
  end
end
