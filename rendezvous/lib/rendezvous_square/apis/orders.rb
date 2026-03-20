module RendezvousSquare
  module Orders
    include Base
    extend self

    def self.api
      # Ensure Base.get_square_client returns the main client
      Base.get_square_client.orders
    end

    def self.search(params)
      post_body = {
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
      
      params = { body: post_body }
      loop do
        begin
          result = api.search(params) || []
          orders = result.orders
        rescue Square::Errors::ResponseError => e
          e.errors.each do |error|
              Rails.logger.error "Square API Error: #{error.category} - #{error.code}: #{error.detail}"
          end
          return nil        
        rescue StandardError => e
          # Catch-all for network timeouts or unexpected issues
          Rails.logger.error "Unexpected Error calling Square: #{e.message}"
          return nil
        end
    end

    def get(order_id)
      begin
        result = api.get(order_id: order_id)
        order = result.order
      rescue Square::Errors::ResponseError => e
        e.errors.each do |error|
            Rails.logger.error "Square API Error: #{error.category} - #{error.code}: #{error.detail}"
        end
        return nil
      rescue StandardError => e
        # Catch-all for network timeouts or unexpected issues
        Rails.logger.error "Unexpected Error calling Square: #{e.message}"
        return nil
      end
    end
  end
end