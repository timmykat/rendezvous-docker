namespace :votable do
  desc "Migrates the vehicle code column to the qr_code code column"
  task migrate_codes: :environment do
    Rails.application.eager_load!
    
    votable_models = ActiveRecord::Base.descendants.select do |model|
      model.included_modules.include?(Votable) && model.column_names.include?("code")
    end

    votable_models.each do |model|
      puts "🔄 Migrating codes for #{model.name}..."

      model.find_each do |record|
        puts record
        votable_code = record.code
        puts votable_code
        qr = QrCode.create(code: votable_code, votable: record)
        if qr.persisted?
          puts "Record saved with QR code"
        else
          puts "Save failure on #{qr.code}"
          exit 0
        end
      end
    end

    puts "Data migration complete"
  end
end