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