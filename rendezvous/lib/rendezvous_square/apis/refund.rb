module RendezvousSquare
  module Checkout
    include Base

    def self.api
      # Note: Added 'self' if you want to call this as a module method
      Base.get_square_client.refunds
    end

    def self.post_refund(params)
      result = api.refund_payment(body: create_refund_body(params))
      if result.success?
        result.data.refund
      else
        Rails.logger.error "Refund Failed: #{result.errors}"
        nil
      end
    end

    def self.all
      refunds_list = []
      # Square API usually expects RFC 3339 strings for times
      params = { begin_time: START_TIME.iso8601 } 
      
      loop do
        begin
          result = api.list_payment_refunds(params)
          
          if result.success?
            # Fix: Variable names must match
            current_batch = result.data.refunds || []
            refunds_list.concat(current_batch)

            if result.cursor
              params[:cursor] = result.cursor
            else
              break
            end
          else
            result.errors.each { |e| Rails.logger.error e.detail }
            return nil
          end
          
        rescue StandardError => e
          Rails.logger.error "Unexpected Error calling Square: #{e.message}"
          return nil
        end
      end
      refunds_list
    end

    private

    def self.create_refund_body(params)
      {
        idempotency_key: SecureRandom.uuid,
        payment_id: params[:payment_id],
        amount_money: {
          amount: params[:amount],
          currency: "USD"
        },
        reason: params[:reason]
      }
    end
  end
end