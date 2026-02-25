Vehicle.destroy_all

file = File.read(Rails.root.join('tmp', "vehicle_backup.json"))
vehicle_data = JSON.parse(file, symbolize_names: true);nil

vehicle_data.each do |attrs|
  puts attrs
  user_email = attrs.delete(:user_email)
  puts user_email
  user = User.find_by(email: user_email)
  puts user
  next unless user

  # Create new vehicles and assign to the user
  vehicle = user.vehicles.create(attrs)
  unless vehicle.persisted?
    raise "Failed to create vehicle for user #{user.email}: #{vehicle.errors.full_messages.join(', ')}"
  end

  puts "Create #{vehicle.year_marque_model}"
end