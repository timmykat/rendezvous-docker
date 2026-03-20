module RendezvousSquare
  module Payments
    include Base
    extend self

    START_TIME = Time.utc(2024, 1, 1)

    def api
      # Ensure Base.get_square_client returns the main client
      Base.get_square_client.payments
    end

    def get_payments
      payment_list = []
      params = { begin_time: START_TIME }
      loop do
        begin
          result = api.list(params) || []
          payments = result.payments
        rescue Square::Errors::ResponseError => e
          # This replaces the 'else' block. Errors are now caught as exceptions.
          # e.errors is an array of Square::Types::Error objects
          e.errors.each do |error|
            Rails.logger.error "Square API Error: #{error.category} - #{error.code}: #{error.detail}"
          end
          return nil
          
        rescue StandardError => e
          # Catch-all for network timeouts or unexpected issues
          Rails.logger.error "Unexpected Error calling Square: #{e.message}"
          return nil
        end
        
        payments_list.concat(payments)

        if result.cursor
          params[:cursor] = result.cursor
        else
          break
        end
      end
      payment_list
    end
  end
end
