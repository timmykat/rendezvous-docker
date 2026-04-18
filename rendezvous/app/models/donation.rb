# == Schema Information
#
# Table name: donations
#
#  id               :bigint           not null, primary key
#  amount           :decimal(6, 2)
#  created_by_admin :boolean          default(FALSE), not null
#  date             :date
#  first_name       :string(255)
#  last_name        :string(255)
#  status           :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  registration_id  :integer
#  user_id          :integer
#
# Indexes
#
#  index_donations_on_date             (date)
#  index_donations_on_registration_id  (registration_id)
#  index_donations_on_user_id          (user_id)
#
class Donation < ApplicationRecord

  include AdminCreatable

  belongs_to :user
  belongs_to :registration, optional: true
  has_one :square_transaction

  enum :status, {
    intialized: 'initialized',
    created: 'created',
    complete: 'complete'
  }

  validate :user_email_format

  validates :user, presence: true

  accepts_nested_attributes_for :user

  def user_email_format
    if user.nil? || /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i !~ user.email
      errors.add(:user, "You must have a correctly formatted email")
    end
  end
end
