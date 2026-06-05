class UnassignedQrGenerationJob < ApplicationJob
  queue_as :qr_generation

  def perform(number = 30)
    number.times do
      QrCode.generate!
    end
  end
end
