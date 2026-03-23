module Square
  class SyncService

    def self.sync_to_ledger(data, type)
      # item can be a Hash (from Webhook) or Object (from SDK)
      # Using data[key] works for both if you use .with_indifferent_access or Hash logic
      item = RendezvousSquare::NormalizedItem.from(data, type: type)

      square_id = item.id

      # 1. Primary Lookup (Fastest)
      reg_id = item.reference_id
      reg = Event::Registration.find_by(id: reg_id) if reg_id.present?
      user = reg&.user

      # 2. Extract context
      transaction_time = item.created_at
      transaction_year = Time.parse(transaction_time.to_s).year

      email =
        if user.present?
          user.email
        elsif item.respond_to?(:customer_email)
          item.customer_email
        elsif item.respond_to?(:buyer_email_address)
          item.buyer_email_address
        elsif item.respond_to?(:receipt_email)
          item.receipt_email
        end

      email = email.downcase.strip if email.present?

      if !user.present? && email.present?
        user = User.find_by(email: email)
      end

      if user && !reg
        reg = user.registrations..find_by(year: transaction_year)
      end

      # Calculate amount: Refunds should be negative
      raw_amount = item.amount_cents || 0
      final_amount = (type == 'refund') ? -raw_amount : raw_amount

      puts "#{type.titleize} #{square_id}: #{item.state}"
      ::Square::Transaction.find_or_create_by!(square_id: square_id, transaction_type: type) do |t|
        t.registration = reg
        t.user = user
        t.email = email
        t.amount_cents = final_amount
        t.currency = item.currency
        t.status = item.state
        t.square_created_at = item.created_at
      end
    end
  end
end
