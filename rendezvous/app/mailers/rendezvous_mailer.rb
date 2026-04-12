class RendezvousMailer < ApplicationMailer

  helper ApplicationHelper

  def send_user_message
    topic = Email::MessageTopics.label(params[:topic]) || 'General'
    subject = params[:subject].to_s.gsub(/[\r\n]/, '')
    @admin = true
    @subject = "#{topic} | #{subject}"
    @name = params[:name]
    @email = params[:email]
    @topic = topic
    @reg_link = params[:registration_link]
    @message = params[:message]

    mail(to: 'tim@wordsareimages.com', reply_to: @email, subject: @subject)
  end

  def send_modification_payment_link(email, modification, payment_link)
    @admin = true
    @modification = modification
    @first_name = modification.registration.user.first_name
    @payment_link = payment_link
    recipients = [email, 'tim@wordsareimages.com']
    mail(to: recipients, subject: 'Rendezvous registration update payment request')
  end

  def no_email_found(email)
    Rails.logger.warn "No email found mailer: " + email
    @email = email
    mail to: @email, subject: 'Incorrect email for sign-in to the Citroen Rendezvous site'
  end

  def send_to_us(name, email, message)
    @admin = true
    @name = name
    @email = email
    @message = message
    recipients = Rails.configuration.people[Rails.env.to_sym][:inquiry_recipients]
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
    @registration = event_registration
    mail(to: @email, subject: "Thanks for registering for the #{Date.current.year} Rendezvous!")
  end

  def send_registration_open_notice(user)
      @name = user.first_name
      @email = user.email
      mail(to: @email, subject: "Rendezvous registration is open for #{Date.current.year}!")
  end
end
