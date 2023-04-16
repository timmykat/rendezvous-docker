# config/initializers/braintree.rb
require 'docker/docker_helper'

include Rendezvous::Docker

unless ENV["BRAINTREE_TOKENIZATION_KEY"] &&  
  ENV['BRAINTREE_MERCHANT_ID'] && 
  ENV['BRAINTREE_PUBLIC_KEY'] &&
  ENV['BRAINTREE_PRIVATE_KEY']

  raise "Cannot find necessary environment variables. See https://github.com/braintree/braintree_rails_example#setup-instructions for instructions";
end

if Rails.env.production? && !docker_env?
  Braintree::Configuration.environment  = :production
else
  Braintree::Configuration.environment  = :sandbox
end

Braintree::Configuration.merchant_id  = ENV['BRAINTREE_MERCHANT_ID']
Braintree::Configuration.public_key   = ENV['BRAINTREE_PUBLIC_KEY']
Braintree::Configuration.private_key  = ENV['BRAINTREE_PRIVATE_KEY']
