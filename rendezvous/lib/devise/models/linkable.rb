module Devise
  module Models
    module Linkable

      extend ActiveSupport::Concern

      # Generates a new random token for confirmation, and stores
      # the time this token is being generated in confirmation_sent_at
      # def generate_login_token
      #   if @user.login_token && !confirmation_period_expired?
      #     @raw_login_token = @user.login_token
      #   else
      #     @user.login_token = @raw_login_token = Devise.friendly_token
      #     @user.confirmation_sent_at = Time.now.utc
      #   end
      # end

      # def generate_login_token!
      #   generate_login_token && save(validate: false)
      # end

      # def confirmation_period_expired?
      #   @user.class.confirm_within && @user.confirmation_sent_at && (Time.now.utc > @user.confirmation_sent_at.utc + @user.class.confirm_within)
      # end



    end
  end
end
