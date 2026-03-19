namespace :square do # Changed from :rake to avoid confusion
  desc "Add Square payment data"
  task init: :environment do
    payments = RendezvousSquare::Payments.get_payments
    
    # Return early if API call failed/returned nil
    if payments.nil?
      puts "Error: Could not retrieve payments."
      next 
    end

    payments.each do |p|
      begin
        data = fetch_data(p)

        user = nil
        if data[:email].present?
          user = User.find_by(email: data[:email])
          puts "User with email #{data[:email]} found" if user
        end

        # Fallback to last name if no email match
        if user.nil? && data[:last_name].present?
          user_list = User.where(last_name: data[:last_name])
          if user_list.size > 1
            puts "Ambiguous: Multiple users with last name #{data[:last_name]}"
          else
            user = user_list.first
          end
        end

        next unless user

        # Update User data
        user.update(square_customer_id: data[:customer_id])

        # Find registration for specific year
        # Note: .where returns a collection, use .find_by or .first
        reg = user.registrations.find_by(year: data[:year])
        
        unless reg
          puts "No registration found for #{user.email} in #{data[:year]}"
          next
        end

        # Use find_or_create to prevent duplicate records on re-runs
        Square::Payment.find_or_create_by!(square_payment_id: data[:payment_id]) do |sp|
          sp.registration = reg
          sp.amount_cents = data[:amount_cents]
          sp.currency     = data[:currency]
        end

      rescue => e
        puts "Skipping payment #{p.id rescue 'unknown'}: #{e.message}"
      end
    end
  end

  # Helper method (must be outside the task block or defined as a lambda)
  def self.fetch_data(p)
    {
      payment_id: p.id,
      customer_id: p.customer_id,
      email: p.buyer_email_address,
      # Dig safely in case billing_address is nil
      last_name: p.billing_address&.last_name, 
      year: Time.parse(p.created_at).year,
      amount_cents: p.amount_money&.amount,
      currency: p.amount_money&.currency
    }
  end
end