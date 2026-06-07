# == Schema Information
#
# Table name: ballots
#
#  id          :bigint           not null, primary key
#  ballot_type :string(255)      not null
#  status      :string(255)
#  year        :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  voter_id    :string(36)
#
# Indexes
#
#  index_ballots_on_ballot_type  (ballot_type)
#  index_ballots_on_voter_id     (voter_id)
#  index_ballots_on_year         (year)
#
module Voting
  class Ballot < ApplicationRecord

    default_scope { where(year: Date.current.year) }

    has_many :ballot_selections, class_name: 'Voting::BallotSelection', dependent: :destroy
    has_many :selections, through: :ballot_selections, source: :votable, source_type: 'Vehicle'

    enum ballot_type: {
      electronic: 'electronic',
      paper: 'paper'
    }

    def self.top_vehicles_by_category(year: Date.current.year, limit: 3)
      vote_counts = Voting::BallotSelection
                    .joins(:ballot)
                    .where(
                      votable_type: 'Vehicle',
                      ballots: { year: year }
                    )
                    .group(:votable_id)
                    .select(:votable_id, 'COUNT(*) AS vote_count')

      Vehicle
        .joins("JOIN (#{vote_counts.to_sql}) AS votes ON votes.votable_id = vehicles.id")
        .select('vehicles.*, votes.vote_count')
        .group_by(&:judging_category)
        .transform_values do |vehicles|
          vehicles
            .sort_by { |vehicle| -vehicle.vote_count.to_i }
            .first(limit)
            .map { |vehicle| [vehicle, vehicle.vote_count.to_i] }
        end
    end

    def categorized_selections
      categorized_selections = Vehicles::VehicleTaxonomy.get_all_categories.map { |k| [k, []] }.to_h
      return categorized_selections unless selections.present?

      selections.each do |vehicle|
        categorized_selections[vehicle.judging_category] << vehicle
      end
      categorized_selections.sort_by { |category, _vehicles| category }.to_h
    end

    def get_status
      return status if status == 'submitted'

      status = 'submissible:all'
      categorized_selections.each_value do |vehicles|
        if vehicles.empty?
          status = 'submissible:some'
        elsif vehicles.length > 1
          status = 'voting'
          break
        end
      end
      save

      status
    end

    def submissible?
      get_status =~ /^submissible/
    end
  end
end
