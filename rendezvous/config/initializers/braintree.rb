# config/initializers/braintree.rb
if Rails.env.production?
  Braintree::Configuration.environment  = :production
else
  Braintree::Configuration.environment  = :sandbox
end
Braintree::Configuration.merchant_id  = ENV['BRAINTREE_MERCHANT_ID']
Braintree::Configuration.public_key   = ENV['BRAINTREE_PUBLIC_KEY']
Braintree::Configuration.private_key  = ENV['BRAINTREE_PRIVATE_KEY']

if !ENV["BRAINTREE_TOKENIZATION_KEY"]
  raise "Cannot find necessary environmental variables. See https://github.com/braintree/braintree_rails_example#setup-instructions for instructions";
end
