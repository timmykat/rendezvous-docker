class ApplicationMailer < ActionMailer::Base
  logger.debug "*** Setting rendezvous sender to #{ENV['RENDEZVOUS_SES_SENDING_ADDRESS']}"
  default from: ENV['RENDEZVOUS_SES_SENDING_ADDRESS']
  layout 'rendezvous_mailer'
end
