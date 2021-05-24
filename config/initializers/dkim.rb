if Rails.env.production?
  Dkim::domain      = 'citroenrendezvous.org'
  Dkim::selector    = 'dkim'
  pem_file = File.expand_path(File.join(File.dirname(__FILE__), '..', 'dkim.pem'))
  Dkim::private_key = open(pemv_file).read

  # This will sign all ActionMailer deliveries
  ActionMailer::Base.register_interceptor(Dkim::Interceptor)
end
