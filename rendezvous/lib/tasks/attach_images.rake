namespace :votable do
  desc "Attaches images to QrCode objects"
  task attach_images: :environment do
    include Rails.application.routes.url_helpers
    Rails.application.eager_load!

    Rails.application.routes.default_url_options[:host] ||= if Rails.env.production?
      'https://citroenrendezvous.org'
    else
      'http://rendezvous.local.wordsareimages.com'
    end
    
    QrCode.all.each do |qr|
      filename = "qr_#{qr.code}.png"
      path = Rails.root.join('public', 'qr_codes', filename)
      puts "Checking path for #{filename}"

      if !File.exist? path
        puts "No image found for #{qr.code} -- generating"
        url = get_voting_ballot_url({code: qr.code})
        QrCode.generate_image(path, url)
      end

      qr.image.attach(
        io: File.open(path),
        filename: filename,
        content_type: 'image/png'
      )
      puts "Image attached for #{qr.code}"
    end
    puts "Image attachments complete"
  end
end