module RendezvousSquare
  module Apis
    module Checkout
      include Apis::Base
      extend self

      FEES = Rails.configuration.pricing[:fees]

      def api
        # Ensure Apis::Base.get_square_client returns the main client
        Apis::Base.get_square_client.checkout
      end

      def create_square_payment_link(params)
        post_body = create_checkout_body(params)

        # Merge the redirect_url into the checkout_options within the body
        post_body[:checkout_options] = {
          redirect_url: params[:redirect_url]
        }

        begin
          # In v45, api.payment_links.create returns a Square::Types::CreatePaymentLinkResponse object directly
          # We use the double splat (**) because the SDK expects keyword arguments
          result = api.payment_links.create(**post_body)

          # ACCESS CHANGE:
          # 1. No 'if result.success?' (if we are here, it succeeded)
          # 2. No '.data' wrapper (the result is the response object)
          # 3. Use '.payment_link.url' or '.payment_link.long_url'
          return result.payment_link.url

        rescue Square::Errors::ResponseError => e
          # This replaces the 'else' block. Errors are now caught as exceptions.
          # e.errors is an array of Square::Types::Error objects
          Rails.logger.error e.message.message
          return "NO VALID LINK"

        rescue StandardError => e
          Rails.logger.error e.message.message
          return "NO VALID LINK"
        end
      end

      def create_checkout_body(params)
        {
          idempotency_key: Apis::Base.idempotency_key,
          order: Api::Orders.create(params)
        }
      end
    end
  end
end
