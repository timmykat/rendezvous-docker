class QrCodesController < ApplicationController

  def generate_vehicle_codes
    if params[:all_vehicles].present?
      Rails.logger.debug 'Removing old QR codes'
      QrCode.assigned.destroy_all
    end

    if params[:sync]
      VehicleQrGenerationJob.perform_now(params[:all_vehicles])
    else
      Rails.logger.debug 'Submitting generation job'
      VehicleQrGenerationJob.perform_later(params[:all_vehicles])
      flash_notice 'Vehicle QR generation job started'
    end
    redirect_to admin_vehicle_dashboard_path
  end

  def generate_unassigned_codes
    if params[:sync]
      UnassignedQrGenerationJob.perform_now
    else
      Rails.logger.debug 'Submitting generation job'
      UnassignedQrGenerationJob.perform_later
      flash_notice 'Unassigned QR generation job started'
    end
    redirect_to admin_vehicle_dashboard_path
  end

  def autocomplete
    qr_code = QrCode.find_by_code(params[:code])
    if !qr_code.nil?
      render json: {
        status: 'OK',
        id: qr_code.id
      }
    end
  end
end
