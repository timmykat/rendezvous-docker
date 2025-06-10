module UsersHelper
  def sign_in_path
    '/users/sign_in'
  end

  def has_registration_and_vehicle(user)
    !user.current_registration.nil? && user.vehicles.present?
  end
end
