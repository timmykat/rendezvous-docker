# == Schema Information
#
# Table name: modifications
#
#  id                   :bigint           not null, primary key
#  delta_adults         :integer          default(0), not null
#  delta_children       :integer          default(0), not null
#  delta_lake_cruise    :integer          default(0), not null
#  delta_youths         :integer          default(0), not null
#  modification_total   :decimal(8, 2)    default(0.0)
#  new_attendee_fee     :decimal(8, 2)    default(0.0)
#  new_lake_cruise_fee  :decimal(8, 2)    default(0.0)
#  new_total            :decimal(8, 2)    default(0.0)
#  starting_adults      :integer          default(0), not null
#  starting_children    :integer          default(0), not null
#  starting_lake_cruise :integer          default(0), not null
#  starting_youths      :integer          default(0), not null
#  status               :string(255)      default("new"), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  registration_id      :integer          not null
#
# Indexes
#
#  index_modification_on_registration_id  (registration_id)
#
# Foreign Keys
#
#  fk_rails_...  (registration_id => registrations.id)
#
module Event
  class Modification < ApplicationRecord

    self.table_name = 'modifications'

    belongs_to :registration
    has_many :attendees, through: :registration

    STATUSES = [
      'new',
      'in progress',
      'complete'
    ].freeze

  end
end
