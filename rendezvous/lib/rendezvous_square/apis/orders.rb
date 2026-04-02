module RendezvousSquare
  module Apis
    module Orders
      include Apis::Base

      STATUSES = %w[OPEN COMPLETED CANCELED].freeze

      def self.api
        # Ensure Apis::Base.get_square_client returns the main client
        Apis::Base.get_square_client.orders
      end

      def self.create(params = {})
        post_body = create_order_body(params)
        result = api.create(...post_body)
        result.order
      end


      def self.create_order_body(params = {})
        post_body = {}
        post_body[:idempotency_key] = Apis::Base.idempotency_key
        post_body[:location_id]  = Apis::Base.get_location_id
        post_body[:line_items] = create_line_items(params)
        post_body[:ticket_name]  = params[:order_type] # Optional helper for Square dashboard,
        post_body[:reference_id] = params[:registration].id # registration ID
      end

      def create_registration_order_body(params)
        {
          location_id: Apis::Base.get_location_id,
          customer_id: params[:customer_id],
          line_items: create_line_items(params[:registration], params[:fee_period]),
          ticket_name: "Event Registration", # Optional helper for Square dashboard,
          reference_id: params[:registration].id # registration ID
        }
      end

      def self.create_donation_order_body(params)
        {
          location_id: Apis::Base.get_location_id,
          customer_id: params[:customer_id],
          line_items: create_donation_line_item(params[:donation]),
          ticket_name: "Donation", # Optional helper for Square dashboard,
          reference_id: params[:registration].id # registration ID
        }
      end

      def self.create_line_items(params)
        line_items = []

        if params[:registration]
          line_items = create_registration_line_items(params)
        end

        if params[:donation]
          line_items = create_donation_line_item
        end

        line_items
      end

      def self.create_registration_line_items
        registration = params[:registration]
        period = params[:fee_period].to_sym

        line_items = []
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

      def self.create_attendee_line_item(number, period, age)
        {
          quantity: number.to_s,
          catalog_object_id: FEES[period]["#{age}_id".to_sym][Apis::Base.get_environment.downcase.to_sym],
          note: "Period: #{period} | Age: #{age}"
        }
      end

      def self.create_cruise_line_item(number)
        {
          quantity: number.to_s,
          catalog_object_id: FEES[:lake_cruise][:catalog_id][Apis::Base.get_environment.downcase.to_sym]
        }
      end

      def self.create_donation_line_item(amount)
        {
          name: "#{Date.current.year} Citroen Rendezvous donation",
          item_type: 'ITEM',
          quantity: '1',
          base_price_money: {
            amount: Apis::Base.integerize(amount),
            currency: 'USD'
          }
        }
      end

      def self.search(params = {})
        if params.blank?
          params = {
            location_ids: [Apis::Base.get_location_id],
            state_filter: {
              status: ['COMPLETED']
            },
            date_time_filter: {
              created_at: {
                start_at: '2023-01-01T00:00:00Z',
                end_at: '2026-12-31T23:59:59Z'
              }
            },
            sort: {
              sort_field: 'CREATED_AT',
              sort_order: 'DESC'
            }
          }
          return Apis::Base.get_all(api, 'search', **params)
        end
      end

      def get(order_id)
        begin
          result = api.get(order_id: order_id)
          order = result.order
        rescue Square::Errors::ResponseError => e
          Rails.logger.error e.message.messaged
          return nil
        rescue StandardError => e
          Rails.logger.error e.message.message
          return nil
        end
      end
    end
  end
end
