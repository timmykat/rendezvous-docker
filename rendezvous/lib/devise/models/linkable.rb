module Devise
  module Models
    module Linkable

      extend ActiveSupport::Concern

      # Generates a new random token for confirmation, and stores
      # the time this token is being generated in confirmation_sent_at
      # def generate_confirmation_token
      #   if @user.confirmation_token && !confirmation_period_expired?
      #     @raw_confirmation_token = @user.confirmation_token
      #   else
      #     @user.confirmation_token = @raw_confirmation_token = Devise.friendly_token
      #     @user.confirmation_sent_at = Time.now.utc
      #   end
      # end

      # def generate_confirmation_token!
      #   generate_confirmation_token && save(validate: false)
      # end

      # def confirmation_period_expired?
      #   @user.class.confirm_within && @user.confirmation_sent_at && (Time.now.utc > @user.confirmation_sent_at.utc + @user.class.confirm_within)
      # end
      def initialize(*args, &block)
        @raw_login_token = nil
        super
      end

      def self.required_fields(klass)
        required_methods = [:confirmation_token, :confirmed_at, :confirmation_sent_at]
        required_methods
      end

      def send_login_link
        generate_login_token!
        send_devise_notification(:email_login_link, @raw_login_token)
      end

      protected 
        # Unlike confirmable, always generate a new token
        def generate_login_token          
          self.confirmation_token = @raw_login_token = Devise.friendly_token
          self.confirmation_sent_at = Time.now.utc
        end

        def generate_login_token!
          generate_login_token && save(validate: false)
          @raw_login_token
        end
    end
  end
end
