class QrGenerationJob < ApplicationJob
  queue_as :qr_generation

  def perform(regenerate = false)
    scope = regenerate ? Vehicle.all : Vehicle.where(code: nil)

    scope.find_each do |vehicle|
      vehicle.update!(qr_code: QrCode.generate!)
    end
  end
end
