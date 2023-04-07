class ApplicationMailer < ActionMailer::Base
  default from: ENV['RENDEZVOUS_SES_SENDING_ADDRESS']
  layout 'rendezvous_mailer'
end
