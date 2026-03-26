# frozen_string_literal: true

module Square
  class EventHandler
    def self.handle(item, type)

      case type
      when 'payment.created', 'payment.updated'
        handle_payment(item)
      when 'refund.created', 'refund.updated'
        handle_refund(item)
      when 'order.created', 'order.updated'
        handle_order(item)
      end

      log_transaction(item, type)
    end

    def handle_payment(item)
      registration = Registration.find_by(square_order_id: payment.order_id)
      return unless registration.present?

      case payment.status
      when "COMPLETED"
        registration.was_paid(item.amount)
        RegistrationPaid.call(registration, payment)
      when "FAILED", "CANCELED"
        RegistrationFailed.call(registration, payment)
      end
    end

    def self.log_transaction(item, type)
      ledger_type = case type
                    when /order/ then 'order'
                    when /payment/ then 'payment'
                    when /refund/ then 'refund'
                    end
      Square::SyncService.sync_to_ledger(payload, ledger_type, square_id)
    end
  end
end