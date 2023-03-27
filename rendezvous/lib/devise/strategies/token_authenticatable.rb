require 'devise/strategies/database_authenticatable'

module Devise
  module Strategies
    # Default strategy for signing in a user, based on their email and password in the database.
    class TokenAuthenticatable < DatabaseAuthenticatable
      
      attr_accessor :email, :confirmation_token, :confirmed_at

      def authenticate!
        puts '*** Calling TokenAuth authenticate! ***'
        resource  = confirmation_token.present? &&  mapping.to.find_for_token_authentication(authentication_hash)

        hashed = false
        if validate(resource) { hashed = true; resource.valid_confirmation_token?(confirmation_token) }
          remember_me(resource)
          resource.after_token_authentication
          success!(resource)
        end

        # In paranoid mode, hash the password even when a resource doesn't exist for the given authentication key.
        # This is necessary to prevent enumeration attacks - e.g. the request is faster when a resource doesn't
        # exist in the database if the password hashing algorithm is not called.
        mapping.to.new.confirmation_token = confirmation_token if !hashed && Devise.paranoid
        unless resource
          Devise.paranoid ? fail(:invalid) : fail(:not_found_in_database)
        end
      end
    end
  end
end

Warden::Strategies.add(:token_authenticatable, Devise::Strategies::TokenAuthenticatable)
