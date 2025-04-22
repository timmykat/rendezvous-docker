require 'rqrcode'
require 'mini_magick'
require 'chunky_png'

namespace :votable do
  desc "Generate QR codes images for vehicles"
  task generate_qr_images: :environment do
    Vehicle.find_each do |vehicle|
      create_qr_code(vehicle.code)
    end
  end

  def create_qr_code(code)
    qr = RQRCode::QRCode.new(code)

    qr_png = qr.as_png(border_modules: 4, size: 300)
    qr_image = MiniMagick::Image.read(qr_png.to_s)
    qr_dir = Rails.root.join('public', 'qr_codes')
    FileUtils.mkdir_p(qr_dir) unless Dir.exist?(qr_dir)
    qr_path = Rails.root.join(qr_dir, "qr_#{code}.png")

    logo_path = Rails.root.join('app', 'assets', 'images', 'oval-citroen-logo.png')

    # Check if the logo image exists
    if File.exist?(logo_path)
      # Open the logo image
      logo = MiniMagick::Image.open(logo_path)
  
      # Resize the logo
      logo.resize("100x100")

      qr_width = qr_image.width
      qr_height = qr_image.height

      qr_image = qr_image.composite(logo) do |c|
        c.compose "Over"  # Set the composite mode to "Over"
        c.gravity "Center"  # Center the logo in the QR code
      end

      qr_image.write(qr_path)
      puts "QR code with image generated successfully and saved to #{qr_path}!"
    else
      puts "⚠️ Image not found at #{logo_path}"
    end
  end
end

