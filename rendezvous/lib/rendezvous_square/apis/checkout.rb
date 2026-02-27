module RendezvousSquare
  module Checkout
    include Base
    
    extend self

    FEES = Rendezvous.configuration.registration.fees

    def api
      client = get_square_client
      return client.checkout
    end

    def integerize(currency_amount)
      (currency_amount * 100).round()
    end

    def create_square_payment_link(object, customer_id, redirect_url)
      post_body = create_checkout_body(object, customer_id)

      post_body[:checkout_options] = {
        redirect_url: redirect_url
      }
  
      result = api.create_payment_link(body: post_body)
  
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
          line_items: create_line_items(registration)
        }
    end

    def create_line_items(registration)
      line_items = []
      period = fee_period.to_s.titlecase
      
      line_items << create_attendee_line_item(registration.number_of_adults, period, 'Adult')
      if registration.number_of_youths.to_i.positive?
        line_items << create_attendee_line_item(registration.number_of_youths, period, 'Youth')
      end
      if registration.number_of_children.to_i.positive?
        line_items << create_attendee_line_item(registration.number_of_children, period, 'Child')
      end
      if registration.donation.positive?
        line_items << create_donation_line_item(registration.donation)
      end
      line_items
    end

    def create_attendee_line_item(number, period, age)
      {
        quantity: number.to_s,
        catalog_object_id: RendezvousSquare::Catalog::REG_ITEM_LOOKUP[period][age],
        note: "Period: #{period} | Age: #{age}"
      }
    end

    def create_donation_line_item(amount)
      {
        name: "#{Date.current.year.to_s} Citroen Rendezvous donation",
        quantity: "1",
        base_price_money: {
          amount: integerize(amount.to_f),
          currency: "USD"
        }
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