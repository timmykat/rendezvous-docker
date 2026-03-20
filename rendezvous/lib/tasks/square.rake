namespace :square do
  desc "Sync Orders, Payments, and Refunds"
  task sync: :environment do

    puts "Starting Square Sync: #{Time.current}"

    # 1. SYNC ORDERS
    puts "Checking orders..."
    RendezvousSquare::Orders.search.each do |ord|
      Square::SyncService.sync_to_ledger(ord, 'order')
    rescue => e
      puts "  [Error] Order #{ord.id}: #{e.message}"
    end

    puts "Checking payments..."
    RendezvousSquare::Payments.all.each do |pmt|
      Square::SyncService.sync_to_ledger(pmt, 'payment')
    rescue => e
      puts "  [Error] Payment #{pmt.id}: #{e.message}"
    end

    puts "Checking payments..."
    RendezvousSquare::Refunds.all.each do |ref|
      Square::SyncService.sync_to_ledger(ref, 'refund')
    rescue => e
      puts "  [Error] Refund #{ref.id}: #{e.message}"
    end
  end
end