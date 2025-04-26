class Vehicle < ApplicationRecord
  extend VehicleTaxonomy
  include StripWhitespace
  include Votable

  belongs_to :user
  has_many :registrations_vehicles, class_name: 'RegistrationsVehicles', foreign_key: :vehicle_id, dependent: :destroy
  has_many :registrations, class_name: 'Event::Registration', through: :registrations_vehicles

  has_many :ballot_selections, as: :votable, class_name: 'Voting::BallotSelection', dependent: :destroy
  has_many :ballots, through: :ballot_selection

  scope :for_sale, -> { where(for_sale: true) }
  
  validates :year, inclusion: { in: (1919..2025).map{ |int| int.to_s }, message: "%{value} is not a valid year" }
  validates :marque, presence: true
  validates :code, presence: true, uniqueness: true

  def self.find_by_qr_code(code)
    Vehicle.where("UPPER(code) = ?", code.upcase).first
  end
  
  def full_spec
    "#{year} #{marque} #{model}  <br /><em>Judging category: #{judging_category}</em>".html_safe
  end
  
  def year_marque_model
    "#{year} #{marque} #{model}"
  end

  def year_marque_model_sale
    "#{year_marque_model}#{for_sale ? ' ---- For sale' : ""}"
  end
  
  def judging_category
    VehicleTaxonomy.get_category(self)
  end

  def voting_info_format
    info = <<~EOF
    <div class="selection">
        <div class="category mb-3 font-weight-bold">Category: #{self.judging_category}</div>
        <div class="info">
          <div class="vehicle">#{self.year_marque_model}</div>
          <div class="owner">Owner: #{self.user.full_name}</div>
        </div>
    </div>
    EOF

    info.html_safe
  end
  
  def at_event?(registration)
    registrations.each do |r|
      if r == registration
        return true
      end
    end
    return false
  end

  def create_qr_code
    qr = RQRCode::QRCode.new(self.code) 
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