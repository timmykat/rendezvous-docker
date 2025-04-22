module Voting
  class Ballot < ApplicationRecord
    
    STATUSES = ["voting", "submissible:some", "submissible:all", "submitted"]

    validates :status, presence: true, inclusion: STATUSES
    # year

    belongs_to :user
    has_many :ballot_selections, class_name: 'Voting::BallotSelection'
    has_many :selections, through: :ballot_selections, source: :votable, source_type: 'Vehicle'

    def categorized_selections
      categorized_selections = VehicleTaxonomy.get_all_categories.map { |k| [k, []] }.to_h
      return categorized_selections if selections.nil? || selections.empty?
      selections.each do |vehicle|
        categorized_selections[vehicle.judging_category] << vehicle
      end
      categorized_selections
    end

    def get_status
      return status if status == 'submitted'
      status = 'submissible:all'
      categorized_selections.each do |category, vehicles|
        if vehicles.length == 0
          status = 'submissible:some'
        elsif vehicles.length > 1
          status = 'voting'
          break
        end
      end
      self.save
      return status
    end      


    def submissible?
      get_status =~ /^submissible/
    end
  end
end