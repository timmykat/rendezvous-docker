class QrCodesController < ApplicationController

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