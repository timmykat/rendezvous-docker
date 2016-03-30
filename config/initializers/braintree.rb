# config/initializers/braintree.rb
if Rails.env.production?
  Braintree::Configuration.environment  = :production
else
  Braintree::Configuration.environment  = :sandbox
end
Braintree::Configuration.merchant_id  = ENV['RENDEZVOUS_BRAINTREE_MERCHANT_ID']
Braintree::Configuration.public_key   = ENV['RENDEZVOUS_BRAINTREE_PUBLIC_KEY']
Braintree::Configuration.private_key  = ENV['RENDEZVOUS_BRAINTREE_PRIVATE_KEY']
