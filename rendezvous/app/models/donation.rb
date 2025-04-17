class Donation < ApplicationRecord
  
  belongs_to :user
  belongs_to :registration, optional: true
  has_one :square_transaction

  STATUSES = ['initialized', 'created', 'complete']

  validates :status, inclusion: { in: STATUSES }

  validate :user_email_format

  validates :user, presence: true

  accepts_nested_attributes_for :user

  def user_email_format
    if user.nil? || /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i !~ user.email 
      errors.add(:user, "You must have a correctly formatted email")
    end
  end
end
