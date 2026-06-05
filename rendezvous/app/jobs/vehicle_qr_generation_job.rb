class VehicleQrGenerationJob < ApplicationJob
  queue_as :qr_generation

  def perform(all_vehicles = false)
    scope = all_vehicles ? Vehicle.all : Vehicle.where(code: nil)

    scope.find_each do |vehicle|
      vehicle.update!(qr_code: QrCode.generate!)
    end
  end
end
