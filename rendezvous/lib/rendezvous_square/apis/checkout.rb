module RendezvousSquare
  module Checkout
    include Base
    
    extend self

    def api
      client = get_square_client
      return client.checkout
    end

    def integerize(currency_amount)
      (currency_amount * 100).round()
    end

    def create_square_payment_link(registration, customer_id, redirect_url)
      post_body = create_checkout_body(registration, customer_id)

      post_body[:checkout_options] = {
        redirect_url: redirect_url
      }

      Rails.logger.info("Checkout link post body")
      Rails.logger.info(post_body)
  
      result = api.create_payment_link(body: post_body)
  
      if result.success?
        Rails.logger.info result.data.payment_link[:url]
        return result.data.payment_link[:long_url]
      elsif result.error?
        Rails.logger.error result.errors
        return "NO VALID LINK"
      end
    end

    def create_checkout_body(registration, customer_id)
      return {
        idempotency_key: Base.idempotency_key,
        order: create_order_object(registration, customer_id)
      }
    end

    def create_order_object(registration, customer_id)
      return {
          source: {
            name: "web registration"
          },
          location_id: SQUARE_LOCATION_ID,
          customer_id: customer_id,
          line_items: [
            {
              name: Date.current.year.to_s + " Rendezvous registration",
              quantity: "1",
              base_price_money: {
                amount: integerize(registration.total),
                currency: "USD"
              },
              note: "Registration ID: " + registration.id.to_s
            }
          ]
        }
    end   
  end
end