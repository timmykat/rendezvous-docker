namespace :square do
  desc "Sync Orders, Payments, and Refunds"
  task sync: :environment do
    # Helper to clean up Square data
    parse_data = ->(item) {
      {
        square_id:        item.id,
        email:            item.try(:buyer_email_address)&.downcase&.strip || item.try(:customer_email)&.downcase&.strip,
        registration_id:  item.try(:reference_id), # Square often puts our Reg ID here
        amount_cents:     item.amount_money&.amount,
        currency:         item.amount_money&.currency || 'USD',
        status:           item.status,
        created_at:       item.created_at
      }
    }

    # 1. SYNC ORDERS
    RendezvousSquare::Orders.search.each do |ord|
      sync_to_ledger(ord, 'order')
    end

    RendezvousSquare::Payments.all.each do |pmt|
      sync_to_ledger(pmt, 'payment')
    end

    RendezvousSquare::Refunds.all.each do |ref|
      sync_to_ledger(ref, 'refund')
    end


    def sync_to_ledger(item, type)
      # 1. Primary Lookup (Fastest)
      reg_id = item.try(:reference_id)
      reg = Event::Registration.find_by(id: reg_id) if reg_id.present?

      # 2. Extract context
      transaction_time = item.created_at
      transaction_year = Date.parse(transaction_time.to_s).year
      email = (item.try(:buyer_email_address) || item.try(:customer_email))&.downcase&.strip

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
      raw_amount = item.try(:amount_money)&.amount || 0
      final_amount = (type == 'refund') ? -raw_amount : raw_amount
  
      SquareTransaction.find_or_create_by!(square_id: item.id, transaction_type: type) do |t|
        t.registration      = reg
        t.user              = user
        t.email             = email
        t.amount_cents      = final_amount
        t.status            = item.status
        t.square_created_at = item.created_at
      end
    end
  end
end