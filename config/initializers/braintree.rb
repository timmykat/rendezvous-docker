# config/initializers/braintree.rb
Braintree::Configuration.environment  = :sandbox
Braintree::Configuration.merchant_id  = ENV['RENDEZVOUS_BRAINTREE_MERCHANT_ID']
Braintree::Configuration.public_key   = ENV['RENDEZVOUS_BRAINTREE_PUBLIC_KEY']
Braintree::Configuration.private_key  = ENV['RENDEZVOUS_BRAINTREE_PRIVATE_KEY']
