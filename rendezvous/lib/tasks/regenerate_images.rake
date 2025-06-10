namespace :votable do
  desc "Regenerate codes for all models that include Votable and have a code column"
  task regenerate_images: :environment do
    Rails.application.eager_load!
    
    Dir.glob(Rails.root.join('public', 'qr_codes', '*')).each do |file|
      File.delete(file) if File.file?(file)
    end
  
    QrCode.all.each do |qr|
      url = QrCode.generate_image(qr.code)
      puts "Image generated: #{url}"
    end

    puts "🎉 Code image regeneration complete!"
  end
end