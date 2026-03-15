# == Schema Information
#
# Table name: scheduled_events
#
#  id                :bigint           not null, primary key
#  day               :string(255)
#  has_subevents     :boolean
#  long_description  :text(65535)
#  name              :string(255)
#  order             :integer
#  short_description :text(65535)
#  time              :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  main_event_id     :bigint
#  venue_id          :bigint
#
# Indexes
#
#  index_scheduled_events_on_day            (day)
#  index_scheduled_events_on_has_subevents  (has_subevents)
#  index_scheduled_events_on_main_event_id  (main_event_id)
#  index_scheduled_events_on_order          (order)
#  index_scheduled_events_on_venue_id       (venue_id)
#
# Foreign Keys
#
#  fk_rails_...  (main_event_id => scheduled_events.id)
#  fk_rails_...  (venue_id => venues.id)
#
class ScheduledEvent < ApplicationRecord
  belongs_to :venue, optional: true

  include MarkdownConcern
  markdown_attributes :short_description, :long_description

  include RailsSortable::Model
  set_sortable :order

  include SortingConcern

  belongs_to :main_event, class_name: 'ScheduledEvent', optional: true
  has_many :sub_events, class_name: 'ScheduledEvent', foreign_key: 'main_event_id', dependent: :nullify

  def is_sub_event?
    main_event.present?
  end

  validates :name, presence: true
  validates :time, presence: true
end
