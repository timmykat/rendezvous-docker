# app/controllers/webhooks/square_controller.rb
module Square
  class WebhooksController < ApplicationController
    skip_before_action :verify_authenticity_token

    def receive
      if is_from_square?
        params = JSON.parse(request.raw_post)

        event_type = params["type"]
        payload = params.dig("data", "object")

        ledger_type = case event_type
          when /order/   then 'order'
          when /payment/ then 'payment'
          when /refund/  then 'refund'
        end

        if ledger_type
          # Re-use the exact same logic from your Rake task
          Square::SyncService.sync_to_ledger(payload, ledger_type)
          head :ok
        else
          head :unprocessable_entity
        end
      else
        render json: { error: 'Invalid signature' }, status: :unauthorized
      end
    end
  
    private

    def is_from_square?
      signature = request.headers['x-square-hmacsha256-signature']
      key = Rails.configuration.square.dig(:signature_key)
      url = Rails.configuration.square.dig(:notification_url)
      
      RendezvousSquare.is_valid_webhook_event_signature(request.raw_post, signature, key, url)
    end
  end
end