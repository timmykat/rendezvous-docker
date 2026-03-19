module RendezvousSquare
  module Checkout
    include Base
    extend self

    FEES = Rails.configuration.pricing[:fees]

    def api
      # Ensure Base.get_square_client returns the main client
      Base.get_square_client.checkout
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
        e.errors.each do |error|
          Rails.logger.error "Square API Error: #{error.category} - #{error.code}: #{error.detail}"
        end
        return "NO VALID LINK"
        
      rescue StandardError => e
        # Catch-all for network timeouts or unexpected issues
        Rails.logger.error "Unexpected Error calling Square: #{e.message}"
        return "NO VALID LINK"
      end
    end

    def create_checkout_body(params)
      # Consistent use of params for both paths
      order_object = if params[:registration]
                       create_order_registration_object(params)
                     elsif params[:donation]
                       create_order_donation_object(params[:donation], params[:customer_id])
                     end

      {
        idempotency_key: Base.idempotency_key,
        order: order_object
      }
    end

    def create_order_registration_object(params)
      {
        location_id: Base.get_location_id,
        customer_id: params[:customer_id],
        line_items: create_line_items(params[:registration], params[:fee_period]),
        ticket_name: "Event Registration" # Optional helper for Square dashboard,
        reference_id: params[:registration].id  #registration ID
      }
    end

    def create_line_items(registration, fee_period)
      line_items = []
      period = fee_period.to_sym
      
      line_items << create_attendee_line_item(registration.number_of_adults, period, 'adult')
      
      if registration.number_of_youths.to_i.positive?
        line_items << create_attendee_line_item(registration.number_of_youths, period, 'youth')
      end
      
      if registration.number_of_children.to_i.positive?
        line_items << create_attendee_line_item(registration.number_of_children, period, 'child')
      end

      if registration.lake_cruise_number.to_i.positive?
        line_items << create_cruise_line_item(registration.lake_cruise_number)
      end
      
      if registration.donation.to_d.positive?
        line_items << create_donation_line_item(registration.donation)
      end
      
      line_items
    end

    def create_attendee_line_item(number, period, age)
      {
        quantity: number.to_s,
        catalog_object_id: FEES[period]["#{age}_id".to_sym][Base.get_environment.downcase.to_sym],
        note: "Period: #{period} | Age: #{age}"
      }
    end

    def create_cruise_line_item(number)
      {
        quantity: number.to_s,
        catalog_object_id: FEES[:lake_cruise][:catalog_id][Base.get_environment.downcase.to_sym]
      }
    end

    def create_donation_line_item(amount)
      {
        name: "#{Date.current.year} Citroen Rendezvous donation",
        item_type: "ITEM",
        quantity: "1",
        base_price_money: {
          amount: Base.integerize(amount),
          currency: "USD"
        }
      }
    end
    
    def create_order_donation_object(donation, customer_id)
      {
        location_id: Base.get_location_id,
        customer_id: customer_id,
        line_items: [
          {
            name: "#{Date.current.year} Citroen Rendezvous Donation",
            quantity: "1",
            base_price_money: {
              amount: Base.integerize(donation.amount),
              currency: "USD"
            },
            note: "Non-registration donation"
          }
        ]
      }
    end 
  end
end