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

    def handle_payment_update(data)
      # Only track registration payments
      registration_id = data["reference_id"]
      return if registration_id.blank?
      # Square payments usually have an order_id. 
      # We should ensure the Square::Order exists first.
      square_order = Square::Order.find_or_create_by!(square_order_id: data["order_id"]) do |o|
        # If this is a new order record, we need to link it to the registration
        # via the reference_id passed during the checkout creation
        o.registration_id = data["reference_id"] 
        o.status = "OPEN" # Default status until we get an order.updated webhook
        o.total_amount_cents = data.dig("amount_money", "amount")
      end
    
      payment = Square::Payment.find_or_initialize_by(square_payment_id: data["id"])
      payment.update!(
        square_order: square_order,
        status: data["status"],
        amount_cents: data.dig("amount_money", "amount"),
        currency: data.dig("amount_money", "currency")
      )
    
      update_registration_totals(square_order.registration)
    end
    
    def handle_refund_update(data)
      # Find the local payment this refund belongs to
      payment = Square::Payment.find_by(square_payment_id: data["payment_id"])
      return unless payment
    
      refund = Square::Refund.find_or_initialize_by(square_refund_id: data["id"])
      refund.update!(
        square_payment: payment,
        status: data["status"],
        amount_cents: data.dig("amount_money", "amount"),
        reason: data["reason"]
      )
    
      update_registration_totals(payment.square_order.registration)
    end
    
    def update_registration_totals(registration)
      return unless registration
    
      registration.with_lock do
        # Pull from your new Square tables to update the main Registration record
        # We only count 'COMPLETED' payments and 'COMPLETED' refunds
        net_square_cents = registration.square_net_total_cents 
        
        # Update your legacy columns (converting cents to dollars if that's your DB format)
        registration.update!(
          paid_amount: (net_square_cents / 100.0).to_d
        )
      end
    end
  end
end