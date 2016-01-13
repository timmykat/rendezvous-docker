class Mailer < ApplicationMailer

  def send_to_us(name, email, message)
    @name = name
    @email = email
    @message = message
    mail(to: Rails.configuration.recipients, subject: "New Rendezvous query from #{@name}")
  end
  
  def autoresponse(name, email, message)
    @name = name
    @email = email
    @message = message
    mail(to: @email, subject: 'Thanks for your inquiry about the Citroen Rendezvous')
  end
end
