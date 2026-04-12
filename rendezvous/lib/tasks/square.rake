namespace :square do
  desc "Sync Orders, Payments, and Refunds"
  task sync: :environment do

    puts "Starting Square Sync: #{Time.current}"

    puts "Current transactions: #{::Square::Transaction.count}"

    total = 0

    # 1. SYNC ORDERS
    puts "Syncing orders..."
    count = 0
    complete = 0
    RendezvousSquare::Apis::Orders.search.each do |ord|
      state = Square::SyncService.sync_to_ledger(ord, 'order')
      count += 1
      complete += 1 if state == 'COMPLETE'
    rescue => e
      puts "  [Error] Order #{ord.id}: #{e.message}"
    end
    total += count
    puts "Order records processed: #{count} | complete: #{complete}"

    puts "Syncing payments..."
    count = 0
    complete = 0
    RendezvousSquare::Apis::Payments.all.each do |pmt|
      state = Square::SyncService.sync_to_ledger(pmt, 'payment')
      count += 1
      complete += 1 if state == 'COMPLETE'
    rescue => e
      puts "  [Error] Payment #{pmt.id}: #{e.message}"
    end
    total += count
    puts "Payment updates processed: #{count} | complete: #{complete}"

    puts "Syncing refunds..."
    count = 0
    complete = 0
    RendezvousSquare::Apis::Refunds.all.each do |ref|
      state = Square::SyncService.sync_to_ledger(ref, 'refund')
      count += 1
      complete += 1 if state == 'COMPLETE'
    rescue => e
      puts "  [Error] Refund #{ref.id}: #{e.message}"
    end
    total += count
    puts "Refund updates processed: #{count} | complete: #{complete}"
    puts "Total records synced: #{total}"
    puts "Final transactions: #{::Square::Transaction.count}"
  end

  desc "Sync Orders, Payments, and Refunds"
  task clean: :environment do
    begin
      ::Square::Transaction.destroy_all
    rescue => e
      puts "  [Error] Clean #{e.message}"
    end
  end
end
