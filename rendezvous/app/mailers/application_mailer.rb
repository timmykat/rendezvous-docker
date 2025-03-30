class ApplicationMailer < ActionMailer::Base
  default from: ENV['INFO_SENDING_ADDRESS']
  layout 'rendezvous_mailer'
end
