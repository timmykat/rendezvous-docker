class VendorsController < ApplicationController
  def index
    @vendors = Vendor.all
  end

  def edit
    @vendor = Vendor.find(params[:id])
  end

  def new
    @vendor = Vendor.new
  end

  def create
    @vendor = Vendor.new(vendor_params)
    if !@vendor.save
      flash_alert_now 'There was a problem creating the vendor.'
      flash_alert_now  @vendor.errors.full_messages.to_sentence
      redirect_to new_admin_vendor_path
    else
      flash_notice 'The vendor was successfully created.'
      redirect_to admin_venue_path(@vendor)
    end
  end

  def update
    @vendor = Vendor.update(vendor_params)
    if !@vendor.save
      flash_alert_now 'There was a problem creating the vendor.'
      flash_alert_now  @vendor.errors.full_messages.to_sentence
      redirect_to new_admin_vendor_path
    else
      flash_notice 'The vendor was successfully updated.'
      redirect_to admin_venue_path(@vendor)
    end
  end

  def destroy
    @venue = Vendor.find(params[:id])
    @venue.destroy
    redirect_to admin_venues_path
  end

  def destroy_all
    Vendor.destroy_all
  end

  def import
    import_data "vendors.csv", "Vendor"
  end

  private
  def vendor_params
    params.require(:vendor).permit(
      :name,
      :email,
      :phone,
      :website,
      :address
    )
  end
end
