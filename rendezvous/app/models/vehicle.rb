# == Schema Information
#
# Table name: vehicles
#
#  id         :integer          not null, primary key
#  code       :string(255)
#  for_sale   :boolean
#  marque     :string(255)
#  model      :string(255)
#  other_info :text(65535)
#  year       :string(255)
#  user_id    :integer
#
# Indexes
#
#  index_vehicles_on_code                       (code)
#  index_vehicles_on_for_sale                   (for_sale)
#  index_vehicles_on_marque                     (marque)
#  index_vehicles_on_marque_and_model           (marque,model)
#  index_vehicles_on_marque_and_year_and_model  (marque,year,model)
#  index_vehicles_on_model                      (model)
#  index_vehicles_on_user_id                    (user_id)
#  index_vehicles_on_year                       (year)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Vehicle < ApplicationRecord
  extend VehicleTaxonomy
  include StripWhitespace
  include Votable

  belongs_to :user
  has_many :registrations_vehicles, class_name: 'RegistrationsVehicles', foreign_key: :vehicle_id, dependent: :destroy
  has_many :registrations, class_name: 'Event::Registration', through: :registrations_vehicles

  has_many :ballot_selections, as: :votable, class_name: 'Voting::BallotSelection', dependent: :destroy

  has_one :qr_code, as: :votable, inverse_of: :votable
  accepts_nested_attributes_for :qr_code, allow_destroy: true
  attr_accessor :qr_code_id
  attr_accessor :bringing # for the RegistrationVehicle join table

  after_save :sync_join_table

  scope :for_sale, -> { where(for_sale: true) }
  
  validates :year, inclusion: { in: (1919..2025).map{ |int| int.to_s }, message: "%{value} is not a valid year" }
  validates :marque, presence: true

  def qr_code_id
    qr_code&.id
  end
  
  def qr_code_id=(id)
    @qr_code_id = id
  end

  def self.find_by_code(code)
    qr_code = QrCode.where("UPPER(code) = ?", code.upcase).first
    Vehicle.where(qr_code: qr_code).first
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

  # Ensure the checkbox is checked if it is being brought
  def bringing
    @bringing ||= registrations_vehicles.joins(:registration)
                      .exists?(registrations: { year: Date.current.year })
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

  private 

  def sync_join_table
    current_reg = user.registrations.find_by(year: Date.current.year)
    return unless current_reg

    is_bringing = ActiveModel::Type::Boolean.new.cast(bringing)

    if is_bringing
      registrations_vehicles.find_or_create_by(registration: current_reg)
    else
      registrations_vehicles.where(registration: current_reg).destroy_all
    end    
  end
end
