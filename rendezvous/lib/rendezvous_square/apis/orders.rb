module RendezvousSquare
  module Apis
    module Orders
      include Apis::Base

      STATUSES = %w[OPEN COMPLETED CANCELED].freeze

      FEES = Rails.configuration.pricing[:fees]

      def self.api
        # Ensure Apis::Base.get_square_client returns the main client
        Apis::Base.get_square_client.orders
      end

      def self.create(params = {})
        Rails.logger.debug params
        post_body = {
          idempotency_key: Apis::Base.idempotency_key,
          order: create_order_object(params)
        }
        result = api.create(**post_body)
        result.order
      end


      def self.create_order_object(params = {})
        {
          location_id: Apis::Base.get_location_id,
          customer_id: params[:customer_id],
          line_items: create_line_items(params),
          ticket_name: "2026 Citroen Rendezvous Registration",
          reference_id: params[:registration].id.to_s
        }
      end

      def self.create_modification_order_object(params = {})
        {
          location_id: Apis::Base.get_location_id,
          customer_id: Apis::Customer.find_customer(params[:email]),
          ticket_name: "2026 Citroen Rendezvous Registration - Update",
          reference_id: params[:reference_id].to_s,
          line_items: create_line_items(params)
        }
      end


      def self.create_donation_order_object(params)
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

        if params[:modification]
          line_items = create_modification_line_items(params)
        end

        if params[:donation]
          line_items = create_donation_line_item
        end

        line_items
      end

      def self.create_registration_line_items(params)
        registration = params[:registration]
        period = params[:fee_period].to_sym

        line_items = []
        Event::Registration::AGE_GROUPS.each do |age|
          if registration.send("number_of_#{age.pluralize}").to_i.positive?
            line_items << create_attendee_line_item(registration.send("number_of_#{age.pluralize}"), period, age)
          end
        end

        if registration.lake_cruise_number.to_i.positive?
          line_items << create_cruise_line_item(registration.lake_cruise_number)
        end

        if registration.donation.to_d.positive?
          line_items << create_donation_line_item(registration.donation)
        end
        line_items
      end

      def self.create_modification_line_items(params)
        modification = params[:modification]
        period = params[:fee_period].to_sym

        line_items = []
        Event::Registration::AGE_GROUPS.each do |age|
          if modification.send("delta_#{age.pluralize}").to_i.positive?
            line_items << create_attendee_line_item(modification.send("delta_#{age.pluralize}"), period, age)
          end
        end

        if modification.delta_lake_cruise.to_i.positive?
          line_items << create_cruise_line_item(modification.delta_lake_cruise)
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
