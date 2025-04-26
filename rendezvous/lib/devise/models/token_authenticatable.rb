require 'devise/strategies/token_authenticatable'

module Devise
  module Models
    module TokenAuthenticatable

      extend extend ActiveSupport::Concern

      attr_reader :raw_login_token

      def initialize(*args, &block)
        @raw_login_token = nil
        super
      end

      def self.required_fields(klass)
        required_methods = [:login_token, :login_token_sent_at]
        required_methods
      end

      def send_login_link
        generate_login_token!
        send_devise_notification(:email_login_link, @raw_login_token)
      end

      def expire_token
        self.update_attribute(:login_token_sent_at, nil)
      end

      protected 
        def scanner_friendly_token
          @raw_login_token = SecureRandom.alphanumeric(10)
          digest = Devise.token_generator.digest(self.class, :login_token, @raw_login_token)
          self.login_token = digest
          self.login_token_sent_at = Time.now.utc
        end

        def generate_login_token!
          scanner_friendly_token && save(validate: false)
          @raw_login_token
        end
    end
  end
end