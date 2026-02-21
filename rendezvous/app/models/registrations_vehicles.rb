# == Schema Information
#
# Table name: registrations_vehicles
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  registration_id :integer          not null
#  vehicle_id      :integer          not null
#
# Indexes
#
#  index_registrations_vehicles_on_registration_id  (registration_id)
#  index_registrations_vehicles_on_vehicle_id       (vehicle_id)
#
# Foreign Keys
#
#  fk_rails_...  (registration_id => registrations.id)
#  fk_rails_...  (vehicle_id => vehicles.id)
#
class RegistrationsVehicles < ApplicationRecord
  belongs_to :registration, class_name: 'Event::Registration'
  belongs_to :vehicle

  validate :vehicle_belongs_to_registration_user

  private

  def vehicle_belongs_to_registration_user
    unless vehicle.user == registration.user
      errors.add(:vehicle, "must belong to the event registrant.")
    end
  end
end
