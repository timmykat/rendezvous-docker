module Voting
  class Ballot < ApplicationRecord
    
    STATUSES = ["voting", "submissible:some", "submissible:all", "submitted"]

    validates :status, presence: true, inclusion: STATUSES
    default_scope { where(year: Date.current.year) }

    has_many :ballot_selections, class_name: 'Voting::BallotSelection', dependent: :destroy
    has_many :selections, through: :ballot_selections, source: :votable, source_type: 'Vehicle'

    def categorized_selections
      categorized_selections = VehicleTaxonomy.get_all_categories.map { |k| [k, []] }.to_h
      return categorized_selections unless self.selections.present?
      self.selections.each do |vehicle|
        categorized_selections[vehicle.judging_category] << vehicle
      end
      categorized_selections.sort_by { |_category, vehicles| vehicles.size }.to_h
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