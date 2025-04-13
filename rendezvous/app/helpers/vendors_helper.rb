module VendorsHelper
  def owner_name(vendor)
    return vendor.owner_display_name if vendor.owner_display_name.present?
    return vendor.owner.full_name if vendor.owner.present?
  end
end
