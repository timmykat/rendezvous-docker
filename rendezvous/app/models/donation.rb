class Donation < ApplicationRecord
  
  belongs_to :user
  belongs_to :registration, optional: true

  STATUSES = ['created', 'complete']

  validates :status, inclusion: { in: STATUSES }

  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }, presence: true

  validates :user, presence: true
end
