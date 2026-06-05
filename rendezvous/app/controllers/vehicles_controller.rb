class VehiclesController < ApplicationController
  before_action :authenticate_user!, { only: %i[new edit] }
  before_action :require_admin, { only: [:index] }

  def index
    @vehicles = Vehicle.all
  end

  def new
    @vehicle = Vehicle.new
    @available_qr_codes = QrCode.unassigned
  end

  def show
    @vehicle = Vehicle.find(params[:id])
  end

  def edit
    @vehicle = Vehicle.find(params[:id])
    @available_qr_codes = QrCode.unassigned
  end

  def update
    @vehicle = Vehicle.find(params[:i])
    if @vehicle.update(vehicle_params)
      flash_notice 'Updated'
      redirect_to vehicle_path(@vehicle.id)
    else
      flash_alert @vehicle.errors.full_messages.to_sentence
      render :edit
    end
  end

  def create
    @vehicle = Vehicle.create(vehicle_params)
    if @vehicle.persisted?
      flash_notice 'The vehicle was successfully created'
      redirect_to vehicle_path(@vehicle)
    else
      flash_alert @vehicle.errors.full_messages.to_sentence
      render :edit
    end
  end


  def for_sale
    @vehicles = Vehicle.joins(:registrations)
      .merge(Event::Registration.current)
      .where(for_sale: true)
      .distinct
  end

  def ajax_info
    vehicle = Vehicle.find_by_code(params[:code])
    unless vehicle
      render json: { status: 'not found' }
      return
    end

    render json: {
      status: 'ok',
      category: vehicle.judging_category,
      vehicle: vehicle.year_marque_model,
      owner: vehicle.user.full_name
    }
  end

  private
  def vehicle_params
    params.require(:vehicle).permit(
      :year,
      :marque,
      :model,
      :user_id,
      qr_code_attributes: [:id, :code, :_destroy]
    )
  end
end
