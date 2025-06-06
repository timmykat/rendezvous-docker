module Votable
  extend ActiveSupport::Concern

  include Rails.application.routes.url_helpers

  included do
    has_many :ballot_selections, as: :votable, dependent: :destroy
    has_many :ballots, through: :ballot_selections

    validates :code, presence: true, uniqueness: true
    before_validation :generate_unique_code, on: :create
  end

  # Handle anonymous voting
  def vote_by(ballot)
    # Create a ballot selection if it doesn't already exist
    ballot.ballot_selections.find_or_create_by(votable: self)
  end

  # Check if this item has already been voted by the given anonymous voter
  def voted_by?(voter_id)
    ballots.exists?(voter_id: voter_id)
  end

  def qr_path
    File.join('public', 'qr_codes')
  end

  def server_qr_path
    '/qr_codes'
  end

  def server_qr_file_path
    return nil if self.code.nil?
    File.join(server_qr_path, "qr_#{self.code}.png")
  end

  def full_qr_path
    Rails.root.join(qr_path)
  end
  
  def full_qr_file_path
    return nil if self.code.nil?
    File.join(full_qr_path, "qr_#{self.code}.png")
  end

  def qr_server_path
    return nil if self.code.nil?
    
  end

  def create_qr_code(regenerate = false)
    Rails.logger.debug "Regenerating? #{regenerate ? 'Yes' : 'No' }"
    return unless regenerate

    generate_unique_code
    self.save
    url = get_voting_ballot_url({code: self.code})
    qr = RQRCode::QRCode.new(url) 
    qr_png = qr.as_png(border_modules: 4, size: 300)
    qr_image = MiniMagick::Image.read(qr_png.to_s)
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

      qr_image.write(full_qr_file_path)
      puts "QR code with image generated successfully and saved to #{full_qr_file_path}!"
    else
      puts "⚠️ Image not found at #{logo_path}"
    end
  end


  private
    def generate_unique_code
      loop do
        self.code = generate_code
        break unless self.class.exists?(code: code)
      end
    end

    def generate_code(length = 4)
      chars = %w[A C D E F G H J K L M N P Q R T U V W X Y Z 2 3 4 5 6 7 8 9] # User friendly characters
      Array.new(length) { chars.sample }.join
    end
end