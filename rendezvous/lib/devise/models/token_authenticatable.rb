require 'devise/strategies/token_authenticatable'

module Devise
  module Models
    module TokenAuthenticatable

      extend extend ActiveSupport::Concern

      attr_reader :raw_confirmation_token
      attr_accessor :confirmed_at

      def initialize(*args, &block)
        @raw_confirmation_token = nil
        super
      end

      def self.required_fields(klass)
        [:confirmation_token, :confirmed_at]
      end

      def valid_confirmation_token?(confirmation_token)
        Devise::Encryptor.compare(self.class, confirmation_token, raw_confirmation_token)
      end

      def after_token_authentication
        self.update_attribute(:confirmed_at, Time.now.utc)
      end

      protected
        def authentication_hash
          { email: self.email, confirmation_token: self.confirmation_token }
        end
      
    end
  end
end