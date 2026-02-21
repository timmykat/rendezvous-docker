# == Schema Information
#
# Table name: ballot_selections
#
#  id           :bigint           not null, primary key
#  votable_type :string(255)      not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  ballot_id    :bigint
#  votable_id   :bigint           not null
#
# Indexes
#
#  index_ballot_selections_on_ballot_id  (ballot_id)
#  index_ballot_selections_on_votable    (votable_type,votable_id)
#
# Foreign Keys
#
#  fk_rails_...  (ballot_id => ballots.id)
#
module Voting
  class BallotSelection < ApplicationRecord
    belongs_to :ballot, class_name: 'Voting::Ballot'
    belongs_to :votable, polymorphic: true
  end
end
