class VendorsController < ApplicationController

  before_action :require_admin, { except: :index }
  
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
      redirect_to new_vendor_path
    else
      flash_notice 'The vendor was successfully created.'
      redirect_to vendor_path(@vendor)
    end
  end

  def update
    @vendor = Vendor.find(params[:id])
    if !@vendor.update(vendor_params)
      flash_alert_now 'There was a problem creating the vendor.'
      flash_alert_now  @vendor.errors.full_messages.to_sentence
      redirect_to edit_vendor_path(@vendor)
    else
      flash_notice 'The vendor was successfully updated.'
      redirect_to vendors_manage_path
    end
  end

  def destroy
    @vendor = Vendor.find(params[:id])
    @vendor.destroy
    redirect_to vendor_path
  end

  def destroy_all
    Vendor.destroy_all
    redirect_to vendors_manage_path
  end

  def manage
    @vendors = Vendor.all
  end

  def import
    import_data "vendors.csv", "Vendor"
    redirect_to vendors_manaage_path
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
