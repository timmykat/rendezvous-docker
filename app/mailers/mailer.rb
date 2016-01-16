class Mailer < ApplicationMailer

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
end
