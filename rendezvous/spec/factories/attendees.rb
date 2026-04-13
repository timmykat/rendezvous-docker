# Read about factories at https://github.com/thoughtbot/factory_bot

# == Schema Information
#
# Table name: attendees
#
#  id              :integer          not null, primary key
#  attendee_age    :string(255)      default("adult")
#  name            :string(255)
#  sunday_dinner   :boolean
#  volunteer       :boolean
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  registration_id :integer
#
# Indexes
#
#  index_attendees_on_attendee_age   (attendee_age)
#  index_attendees_on_sunday_dinner  (sunday_dinner)
#  index_attendees_on_volunteer      (volunteer)
#
FactoryBot.define do
  factory :attendee do
    registration
    name { 'Andre Citroen' }
    attendee_age { 'adult' }
    volunteer  { false }
    sunday_dinner  { false }
  end
end
