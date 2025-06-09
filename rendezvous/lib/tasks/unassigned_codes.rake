namespace :votable do
  namespace :unassigned_codes do

    desc "Return number of unassigned codes"
    task count: :environment do
      puts "There are #{QrCode.unassigned.count} unassigned QR codes"
    end

    desc "Regenerate codes for all models that include Votable and have a code column"
    task :generate, [:number] =>  :environment do |t, args|
      Rails.application.eager_load!

      puts "Creating #{args[:number]} QR codes"

      (1..(args[:number].to_i)).each do |qr|
        code = QrCode.generate!
        puts "Created code #{code}"
      end

      puts "🎉 Code gen complete!"

    end
  end
end