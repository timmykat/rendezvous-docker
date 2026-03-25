module RendezvousSquare
  module Apis
    module Orders
      include Apis::Base

      STATUSES = %w[OPEN COMPLETED CANCELED]

      def self.api
        # Ensure Apis::Base.get_square_client returns the main client
        Apis::Base.get_square_client.orders
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
end