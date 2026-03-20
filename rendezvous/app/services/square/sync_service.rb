module Square
  class SyncService

    def self.sync_to_ledger(item, type, square_id)
      # item can be a Hash (from Webhook) or Object (from SDK)
      # Using data[key] works for both if you use .with_indifferent_access or Hash logic
      item = item.with_indifferent_access if item.is_a?(Hash)

      Rails.logger.debug item.to_s

      # 1. Primary Lookup (Fastest)
      reg_id = item[:reference_id]
      reg = Event::Registration.find_by(id: reg_id) if reg_id.present?

      # 2. Extract context
      transaction_time = item[:created_at]
      transaction_year = Date.parse(transaction_time.to_s).year
      email = (item[:buyer_email_address] || item[:customer_email])&.downcase&.strip

      # 3. Validation & Fallback
      # If we found a reg by ID, make sure it actually matches the transaction year
      if reg && reg.year != transaction_year
        puts "Warning: Reference ID #{reg_id} belongs to #{reg.year}, but transaction is #{transaction_year}. Falling back to email."
        reg = nil 
      end

      # 4. Email-based Lookup (if ID lookup failed or was the wrong year)
      if email.present?
        user ||= User.find_by(email: email)
        
        # Only look for a reg by email if we don't already have a valid one from Step 1
        if reg.nil? && user
          reg = user.registrations.find_by(year: transaction_year)
        end
      end

      # 5. Final Ownership Sync
      user ||= reg&.user
  
      # Calculate amount: Refunds should be negative
      raw_amount = item[:amount_money]&.amount || 0
      final_amount = (type == 'refund') ? -raw_amount : raw_amount
  
      ::Square::Transaction.find_or_create_by!(square_id: item[:id], transaction_type: type) do |t|
        t.square_id         = square_id
        t.registration      = reg
        t.user              = user
        t.email             = email
        t.amount_cents      = final_amount
        t.status            = item[:state]
        t.square_created_at = item[:created_at]
      end
    end
  end
end
