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

    def create_square_payment_link(object, customer_id, redirect_url)
      post_body = create_checkout_body(object, customer_id)

      Rails.logger.debug post_body

      post_body[:checkout_options] = {
        redirect_url: redirect_url
      }
  
      result = api.create_payment_link(body: post_body)

      Rails.logger.debug result
  
      if result.success?
        return result.data.payment_link[:long_url]
      elsif result.error?
        Rails.logger.error result.errors
        return "NO VALID LINK"
      end
    end

    def create_checkout_body(object, customer_id)
      case object
      when Event::Registration
        return {
          idempotency_key: Base.idempotency_key,
          order: create_order_registration_object(object, customer_id)
        }
      when Donation
        return {
          idempotency_key: Base.idempotency_key,
          order: create_order_donation_object(object, customer_id)
        }
      end
    end

    def create_order_registration_object(registration, customer_id)
      return {
          source: {
            name: "web registration"
          },
          location_id: Base.get_location_id,
          customer_id: customer_id,
          line_items: [
            {
              name: Date.current.year.to_s + " Citroen Rendezvous registration",
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
    
    def create_order_donation_object(donation, customer_id)
      return {
          source: {
            name: "web donation"
          },
          location_id: Base.get_location_id,
          customer_id: customer_id,
          line_items: [
            {
              name: Date.current.year.to_s + " Citroen Rendezvous Donation",
              quantity: "1",
              base_price_money: {
                amount: integerize(donation.amount),
                currency: "USD"
              },
              note: "Non-registration donation"
            }
          ]
        }
    end 
  end
end