class Admin::ScheduledEvent < ApplicationRecord
  belongs_to :venue, optional: true

  validates :name, presence: true
  validates :time, presence: true
end
