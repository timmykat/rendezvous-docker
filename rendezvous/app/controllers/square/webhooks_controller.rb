# app/controllers/webhooks/square_controller.rb
module Square
  class WebhooksController < ApplicationController
    skip_before_action :verify_authenticity_token

    def receive
      unless is_from_square?
        render json: { error: 'Invalid signature' }, status: :unauthorized
        return
      end

      full_payload = JSON.parse(request.raw_post)

      type = full_payload["type"]
      data = full_payload.dig("data", "object")

      item = RendezvousSquare::NormalizedItem.from(data, type: type)

      unless item and type
        head :unprocessable_entity
        return
      end

      begin
        EventHandler.handle(item, type)
      rescue StandardError => e
        Rails.logger.error e.message
        head :unprocessable_entity
        return
      end

      head :ok
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