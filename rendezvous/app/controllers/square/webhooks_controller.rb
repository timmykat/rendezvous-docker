# app/controllers/webhooks/square_controller.rb
module Square
  class WebhooksController < ApplicationController
    skip_before_action :verify_authenticity_token

    def receive
      if is_from_square?
        full_payload = JSON.parse(request.raw_post)

        event_type = full_payload["type"]
        data_obj = full_payload.dig("data", "object")

        payload = case event_type
                  when "order.created" then data_obj["order_created"]
                  when "order.updated" then data_obj["order_updated"]
                  when "payment.updated" then data_obj["payment"]
                  when "refund.created" then data_obj["refund"]
                  else data_obj # Fallback
                  end

        ledger_type = case event_type
                      when /order/ then 'order'
                      when /payment/ then 'payment'
                      when /refund/ then 'refund'
                      end

        if payload and ledger_type
          id_label = "#{ledger_type}_id"
          square_id = payload[id_label]
          Rails.logger.debug "Label: #{id_label}"
          Rails.logger.debug square_id

          # Re-use the exact same logic from your Rake task
          Square::SyncService.sync_to_ledger(payload, ledger_type, square_id)
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

      RendezvousSquare::Util.is_valid_webhook_event_signature(request.raw_post, signature, key, url)
    end
  end
end