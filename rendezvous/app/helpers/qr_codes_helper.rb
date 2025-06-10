module QrCodesHelper
  def qr_code_url(code)
    QrCode.get_image_path(code)
  end
end
