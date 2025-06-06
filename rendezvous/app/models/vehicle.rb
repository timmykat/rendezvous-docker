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
  before_validation :generate_code

  def self.find_by_code(code)
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
      <div class="category">Category: #{self.judging_category}</div>
      <div class="info">
        <div class="vehicle">#{self.year_marque_model}</div>
        <div class="owner">Owner: #{self.user.full_name}</div>
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

  def self.top_3_by_category
    current_year = Date.current.year

    # Subquery: vote counts for current year's ballots
    vote_counts = Voting::BallotSelection
      .joins(:ballot)
      .where(
        votable_type: 'Vehicle',
        ballots: { year: current_year }
      )
      .group(:votable_id)
      .select(:votable_id, 'COUNT(*) AS vote_count')

    # Join Vehicles with vote counts
    vehicles_with_votes = Vehicle
      .joins("JOIN (#{vote_counts.to_sql}) AS votes ON votes.votable_id = vehicles.id")
      .select('vehicles.*, votes.vote_count')
      .index_by(&:id)

    # Group by judging category
    grouped = vehicles_with_votes.values.group_by(&:judging_category)

    # Sort and return top 3 per category
    grouped.transform_values do |vehicles|
      vehicles
        .sort_by { |v| -v.vote_count.to_i }
        .first(3)
        .map { |v| [v, v.vote_count.to_i] }
    end
  end
end