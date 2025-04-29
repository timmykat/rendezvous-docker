namespace :votable do
  desc "Regenerate codes for all models that include Votable and have a code column"
  task regenerate_codes: :environment do
    Rails.application.eager_load!
    
    votable_models = ActiveRecord::Base.descendants.select do |model|
      model.included_modules.include?(Votable) && model.column_names.include?("code")
    end

    votable_models.each do |model|
      puts "🔄 Regenerating codes for #{model.name}..."

      model.find_each do |record|
        old_code = record.code
        loop do
          new_code = record.send(:generate_code)
          unless model.exists?(code: new_code)
            record.update!(code: new_code)
            puts "✅ #{model.name} ID #{record.id}: #{old_code} → #{record.code}"
            break
          end
        end
      end
    end

    puts "🎉 Code regeneration complete!"
  end
end