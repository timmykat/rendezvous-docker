module Votable
  extend ActiveSupport::Concern

  included do
    has_many :ballot_selections, as: :votable, dependent: :destroy
    has_many :ballots, through: :ballot_selections

    before_create :generate_unique_code
  end

  def vote_by(user)
    ballot = ::Voting::Ballot.find_or_create_by(user: user)
    ballot.ballot_selections.find_or_create_by(votable: self)
  end

  def voted_by?(user)
    ballots.exists?(user: user)
  end

  private
    def generate_unique_code
      return if self.code.present?  # Skip if already set manually

      loop do
        self.code = generate_code
        break unless self.class.exists?(code: code)
      end
    end

    def generate_code(length = 6)
      chars = %w[A C D E F G H J K L M N P Q R T U V W X Y Z 1 2 3 4 5 6 7 8 9] # User friendly characters
      Array.new(length) { chars.sample }.join
    end
end