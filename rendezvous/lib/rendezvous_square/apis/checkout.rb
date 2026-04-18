module RendezvousSquare
  module Apis
    module Checkout
      include Apis::Base
      extend self

      def list_payment_links
        response = Base::CLIENT.checkout.payment_links.list
      end

      def create_square_modification_payment_link(params)
        post_body = create_modification_checkout_body(params)
        create_link(post_body)
      end

      def create_square_payment_link(params)
        Rails.logger.debug params
        post_body = create_checkout_body(params)

        # Merge the redirect_url into the checkout_options within the body
        if params[:redirect_url]
          post_body[:checkout_options] = {
            redirect_url: params[:redirect_url]
          }
        end

        create_link(post_body)
      end

      def create_link(post_body)
        begin
          # In v45, api.payment_links.create returns a Square::Types::CreatePaymentLinkResponse object directly
          # We use the double splat (**) because the SDK expects keyword arguments
          response = Base::CLIENT.checkout.payment_links.create(**post_body)

          # ACCESS CHANGE:
          # 1. No 'if response.success?' (if we are here, it succeeded)
          # 2. No '.data' wrapper (the response is the response object)
          # 3. Use '.payment_link.url' or '.payment_link.long_url'
          return response.payment_link.url

        rescue Square::Errors::ResponseError => e
          # This replaces the 'else' block. Errors are now caught as exceptions.
          # e.errors is an array of Square::Types::Error objects
          Rails.logger.error e.message
          return "NO VALID LINK"

        rescue StandardError => e
          Rails.logger.error e.message.message
          return "NO VALID LINK"
        end
      end

      # The Checkout API creates the order, so
      # just need to create the order body, not the actual order
      def create_checkout_body(params)
        if params[:donation]
          order_object = Apis::Orders.create_donation_order_object(params)
        else
          order_object = Apis::Orders.create_order_object(params)
        end
        {
          idempotency_key: Apis::Base.idempotency_key,
          order: order_object
        }
      end

      def create_modification_checkout_body(params)
        order_object = Apis::Orders.create_modification_order_object(params)
        {
          idempotency_key: Apis::Base.idempotency_key,
          order: order_object
        }
      end
    end
  end
end
