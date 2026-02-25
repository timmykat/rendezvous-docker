class QrCode < ApplicationRecord

  belongs_to :votable, polymorphic: true, inverse_of: :qr_code, optional: true

  has_one_attached :image

  validates :code, presence: true, uniqueness: true

  before_validation :generate_unique_code

  scope :unassigned, -> {
    where(votable_type: nil).where(votable_id: nil)
  }

  FILE_BASE = Rails.root.join('public', 'qr_codes')

  include Rails.application.routes.url_helpers
  Rails.application.routes.default_url_options[:host] ||= Rails.application.config.action_mailer.default_url_options[:host]

  def self.generate!(max_attempts = 5)
    attempts = 0
    begin
      qr = QrCode.create!
    rescue ActiveRecord::RecordNotUnique
      attempts += 1
      retry if attempts < max_attempts
      raise
    end
    QrCode.generate_image(qr.code)
    return qr.code
  end

  def assigned?
    votable.present?
  end

  private
  def generate_unique_code
    return if code.present?

    assign_unique_code
  end

  def assign_unique_code
    loop do
      self.code = generate_code
      break unless self.class.exists?(code: code)
    end
  end

  def generate_code(length = 4)
    chars = %w[A C D E F G H J K L M N P Q R T U V W X Y Z 2 3 4 5 6 7 8 9] # User friendly characters
    Array.new(length) { chars.sample }.join
  end

  def self.get_image_path(code)
    File.join('/qr_codes', "qr_#{code}.png")
  end

  def self.generate_image(code)
    filepath = File.join(FILE_BASE, "qr_#{code}.png")
    url = Rails.application.routes.url_helpers.get_voting_ballot_url({code: code})

    qr = RQRCode::QRCode.new(url) 
    qr_png = qr.as_png(border_modules: 4, size: 300)
    qr_image = MiniMagick::Image.read(qr_png.to_s)

    logo_path = Rails.root.join('app', 'assets', 'images', 'oval-citroen-logo.png')

    # Add logo if it exists
    if File.exist?(logo_path)
      # Open the logo image
      logo = MiniMagick::Image.open(logo_path)
  
      # Resize the logo
      logo.resize("100x100")

      qr_image = qr_image.composite(logo) do |c|
        c.compose "Over"  # Set the composite mode to "Over"
        c.gravity "Center"  # Center the logo in the QR code
      end
    end

    qr_image.write(filepath)
    return url    
  end
end
