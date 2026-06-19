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
    @user = @vehicle.user
    @available_qr_codes = QrCode.unassigned
  end

  def update
    @vehicle = Vehicle.find(params[:id])
    new_code_id = params[:new_code].presence

    ActiveRecord::Base.transaction do
      @vehicle.update!(vehicle_params)

      if new_code_id.present?
        qr_code = QrCode.find(new_code_id)

        if @vehicle.qr_code&.id != qr_code.id
          @vehicle.qr_code&.update!(votable: nil)
          qr_code.update!(votable: @vehicle)
        end
      else
        @vehicle.qr_code&.update!(votable: nil)
      end
    end

    flash_notice 'Updated'
    redirect_to vehicle_path(@vehicle)
  rescue ActiveRecord::RecordInvalid => e
    flash_alert e.record.errors.full_messages.to_sentence
    render :edit
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
      :qr_code_id,
      qr_code_attributes: %i[id code _destroy]
    )
  end
end
