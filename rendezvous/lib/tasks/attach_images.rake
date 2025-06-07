namespace :votable do
  desc "Attaches images to QrCode objects"
  task attach_images: :environment do
    Rails.application.eager_load!
    
    QrCode.all.each do |qr|
      filename = "qr_#{qr.code}.png"
      path = Rails.root.join('public', 'qr_codes', filename)
      puts "Checking path for #{filename}"
      if File.exist? path
        qr.image.attach(
          io: File.open(path),
          filename: filename,
          content_type: 'image/png'
        )
        puts "Image attached for #{qr.code}"
      else
        puts "No image found for #{qr.code} -- generating"
        url = get_voting_ballot_url({code: self.code})
        QrCode.
      end
    end
    puts "Image attachments complete"
  end
end