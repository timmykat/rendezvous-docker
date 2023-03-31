require 'devise/strategies/database_authenticatable'

module Devise
  module Strategies
    # Default strategy for signing in a user, based on their email and password in the database.
    class TokenAuthenticatable < Authenticatable
      
      attr_accessor :login_token
      
      def valid?
        Rails.logger.debug params[:login_token].present? ? 'Valid' : 'Not valid'
        params[:login_token].present?
      end

      def authenticate!
        Rails.logger.debug '*** Calling TokenAuth authenticate! ***'
        resource = User.find_by_token(params[:login_token])

        hashed = false
        validity = validate(resource)
        if validity == :valid
          hashed = true
          remember_me(resource)
          resource.after_token_authentication
          Rails.logger.debug "Authentication success!"
          success!(resource)
        else
          Rails.logger.debug "Authentication FAIL"
          fail(validity)
        end

        # In paranoid mode, hash the password even when a resource doesn't exist for the given authentication key.
        # This is necessary to prevent enumeration attacks - e.g. the request is faster when a resource doesn't
        # exist in the database if the password hashing algorithm is not called.
        mapping.to.new.login_token = login_token if !hashed && Devise.paranoid
        unless resource
          Devise.paranoid ? fail(:invalid) : fail(:not_found_in_database)
        end
      end

      def validate(resource)
        return_val = :valid
        if !resource
          return_val = :invalid_token
        elsif expired_token? resource
          return_val = :expired_token
        end
        return_val
      end

      def expired_token?(resource)
        (Time.now.to_i - resource.login_token_sent_at.to_i) > 600
      end
    end
  end
end

Warden::Strategies.add(:token_authenticatable, Devise::Strategies::TokenAuthenticatable)
