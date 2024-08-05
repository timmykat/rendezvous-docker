# config/initializers/braintree.rb

if Rails.env.production?
  Braintree::Configuration.environment  = :production
  prefix = "PROD_"
else
  Braintree::Configuration.environment  = :sandbox
  prefix = "SANDBOX_"
end 

unless ENV[prefix + "BRAINTREE_TOKENIZATION_KEY"] &&  
  ENV[prefix + 'BRAINTREE_MERCHANT_ID'] && 
  ENV[prefix + 'BRAINTREE_PUBLIC_KEY'] &&
  ENV[prefix + 'BRAINTREE_PRIVATE_KEY']

  raise "Cannot find necessary environment variables. See https://github.com/braintree/braintree_rails_example#setup-instructions for instructions";
end

Braintree::Configuration.merchant_id  = ENV[prefix + 'BRAINTREE_MERCHANT_ID']
Braintree::Configuration.public_key   = ENV[prefix + 'BRAINTREE_PUBLIC_KEY']
Braintree::Configuration.private_key  = ENV[prefix + 'BRAINTREE_PRIVATE_KEY']
