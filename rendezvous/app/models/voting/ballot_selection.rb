module Voting
  class BallotSelection < ApplicationRecord
    belongs_to :ballot, class_name: 'Voting::Ballot'
    belongs_to :votable, polymorphic: true
  end
end