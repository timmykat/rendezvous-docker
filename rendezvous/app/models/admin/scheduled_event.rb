class Admin::ScheduledEvent < ApplicationRecord
  belongs_to :venue

  validates :name, presence: true
  validates :time, presence: true
  validates :venue, presence: true
end
