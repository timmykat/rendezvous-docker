module RendezvousSquare
  module Payments
    include Base

    # Ensure this is ISO8601 for the API
    START_TIME = Time.utc(2023, 1, 1).iso8601

    def self.api
      Base.get_square_client.payments
    end

    def self.all
      all_payments = []
      params = { begin_time: START_TIME }
      
      loop do
        begin
          result = api.list_payments(params) # Correct method name
          
          if result.success?
            batch = result.data.payments || []
            all_payments.concat(batch)

            if result.cursor
              params[:cursor] = result.cursor
            else
              break
            end
          else
            # Handle API-level errors (e.g., 401, 429)
            result.errors.each do |error|
              Rails.logger.error "Square API Error: #{error.category} - #{error.code}: #{error.detail}"
            end
            return nil
          end
          
        rescue StandardError => e
          Rails.logger.error "Unexpected Error calling Square: #{e.message}"
          return nil
        end
      end
      all_payments
    end
  end
end