class EventHotelsController < AdminController
  
  def create
    @event_hotel = EventHotel.new(event_hotel_params)
    if !@event_hotel.save
      flash_alert_now 'There was a problem creating the venue.'
      flash_alert_now  @event_hotel.errors.full_messages.to_sentence
      redirect_to new_venue_path
    else
      flash_notice 'The venue was successfully created'
      redirect_to venue_path(@event_hotel)
    end
  end

  def edit
    @event_hotel = EventHotel.find(params[:id])
  end

  def show
    @event_hotel = EventHotel.find(params[:id])
  end

  def event_hotel
    @event_hotel = EventHotel.first
  end

  def update
    @event_hotel = EventHotel.find(params[:id])
    if !@event_hotel.update(event_hotel_params)
      flash_alert_now 'There was a problem updating the venue information'
      flash_alert_now  @event_hotel.errors.full_messages.to_sentence
    end

    @event_hotels = Venue.all
    redirect_to venues_manage_path
  end

  def manage
    @venues = get_objects "Venue"
  end

  def destroy
    @event_hotel = EventHotel.find(params[:id])
    @event_hotel.destroy
    redirect_to venues_manage_path
  end

  private
    def event_hotel_params
      params.require(:event_hotel).permit(
        :name,
        :event_hotel,
        :show_field_venue,
        :phone,
        :email,
        :website,
        :address,
        :details,
        :reservation_url,
        :group_code,
        :rooms_available,
        :close_date,
        :type     
      )
    end
end
