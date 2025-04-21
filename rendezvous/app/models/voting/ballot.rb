module Voting
  class Ballot < ApplicationRecord
    
    STATUSES = ["deciding", "submissable", "voted"]
    # year

    belongs_to :user
    has_many :vehicles

    def votable?
      categories = []
        vehicles.each do |v|
          categories << v.judging_category
          if categories.uniq.length != categories.length
            status = "deciding"
            self.save
            return false
        end
        status = "submissible"
        self.save
        return true
    end
  end
end