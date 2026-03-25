# frozen_string_literal: true

module Square
  class EventHandler
    def self.handle(event)
      case event.type
      when 'payment.updated'
        handle_payment(event.data.object.payment)
      end
    end

    def handle_payment(payment)
      registration = Registration.find_by(square_order_id: payment.order_id)
      return unless registration.present?

      case payment.status
      when "COMPLETED"
        RegistrationPaid.call(registration, payment)
      when "FAILED", "CANCELED"
        RegistrationFailed.call(registration, payment)
      end
    end
  end
end