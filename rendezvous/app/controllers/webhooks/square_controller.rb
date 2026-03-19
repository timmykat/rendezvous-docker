# app/controllers/webhooks/square_controller.rb
module Webhooks
  class SquareController < ApplicationController
    skip_before_action :verify_authenticity_token

    def receive
      if is_from_square?
        payload = JSON.parse(request.raw_post)
        data = payload.dig("data", "object")

        case payload["type"]
        when "payment.updated" then handle_payment_update(data["payment"])
        when "refund.updated"  then handle_refund_update(data["refund"])
        end

        head :ok
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

    def handle_payment_update(payment_data)
      # 1. Find or Create the local Square::Payment record
      payment = Square::Payment.find_by(square_payment_id: payment_data["id"])
      
      if payment.nil?
        # Use the reference_id you passed when creating the Order/Link
        registration_id = payment_data["reference_id"]
        return if registration_id.blank?

        reg = Event::Registration.find_by(id: registration_id)
        return unless reg

        payment = Square::Payment.create!(
          square_payment_id: payment_data["id"], 
          registration: reg, 
          status: payment_data["status"],
          amount_cents: payment_data.dig("amount_money", "amount"),
          currency: payment_data.dig("amount_money", "currency"),
        )
      else
        payment.update(status: payment_data["status"])
        reg = payment.registration
      end
      
      return unless reg

      # 2. Lock and Update Registration
      reg.with_lock do
        # Summation is safer than += to handle potential duplicate webhooks
        total_cents = reg.payments.where(status: "COMPLETED").sum(:amount_cents)
        reg.update!(paid_amount: (total_cents / 100.0).to_d)
      end
    end

    def handle_refund_update(refund_data)
      refund = Square::Refund.find_by(square_refund_id: refund_data["id"])
      
      if refund.nil?
        payment = Square::Payment.find_by(square_payment_id: refund_data["payment_id"])
        return unless payment
        
        refund = Square::Refund.create!(
          payment: payment, 
          square_refund_id: refund_data["id"], 
          status: refund_data["status"],
          amount_cents: refund_data.dig("amount_money", "amount")
        )
      else
        refund.update(status: refund_data["status"])
      end

      reg = refund.registration
      return unless reg

      # 3. Lock and Update Registration Refunds
      reg.with_lock do
        # Use your model helper for the math
        reg.update!(refunded: reg.total_of_refunded)
      end
    end
  end
end