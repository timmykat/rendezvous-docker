class Admin::ScheduledEvent < ApplicationRecord
  include MarkdownConcern

  belongs_to :venue, optional: true

  validates :name, presence: true
  validates :time, presence: true

  markdown_attributes :short_description, :long_description
end
