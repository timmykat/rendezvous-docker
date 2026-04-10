namespace :square do
  desc "Bulk sync square_customer_id using Square customer list"

  task backfill_users: :environment do
    puts 'Fetching Square customers...'

    customer_list = ::RendezvousSquare::Apis::Customers.list

    email_map = {}
    customer_list.each do |c|
      email_map[c.email_address.downcase] = c.id
    end

    processed = 0
    updated = 0
    User.where(square_customer_id: [nil, ""]).find_in_batches(batch_size: 200) do |batch|
      batch.each do |user|
        processed += 1

        customer_id = email_map[user.email.downcase]

        next unless customer_id

        user.update!(square_customer_id: customer_id)
        updated += 1

        puts "✔ Linked #{user.email}"
      end
    end

    puts 'Done!'
    puts "Processed: #{processed}"
    puts "Updated: #{updated}"
  end
end
