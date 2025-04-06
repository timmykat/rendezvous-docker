class VendorsController < ApplicationController

  before_action :require_admin, { except: :index }
  
  def index
    @vendors = Vendor.order(:order).all
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
      redirect_to vendors_manage_path
    end
  end

  def update
    @vendor = Vendor.find(params[:id])
    if !@vendor.update(vendor_params)
      flash_alert_now 'There was a problem creating the vendor.'
      flash_alert_now  @vendor.errors.full_messages.to_sentence
      redirect_to vendors_manage_path
    else
      redirect_to vendors_manage_path
    end
  end

  def manage
    @vendors = get_objects "Vendor"
  end

  def destroy
    @vendor = Vendor.find(params[:id])
    @vendor.destroy
    manage
  end

  def destroy_all
    Vendor.destroy_all
    manage
  end

  def import
    import_data "vendors.csv", "Vendor"
    manage
  end

  private
    def vendor_params
      params.require(:vendor).permit(
        :name,
        :user_id,
        :email,
        :phone,
        :website,
        :address
      )
    end
end
