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
        <div class="vehicle font-weight-bold">#{self.year_marque_model}</div>
        <div class="owner font-weight-bold">Owner: #{self.user.full_name}</div>
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
end