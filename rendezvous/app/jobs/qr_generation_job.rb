class QrGenerationJob < ApplicationJob
  queue_as :default

  def perform(regenerate)
    Vehicle.find_each  do |v|
      v.create_qr_code(regenerate)
    end
  end
end
