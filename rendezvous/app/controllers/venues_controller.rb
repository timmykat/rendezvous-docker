class VenuesController < AdminController
  
  def new
    @venue = Venue.new
    puts @venue
    @venue
  end

  def create
    @venue = Venue.new(venue_params)
    if !@venue.save
      flash_alert_now 'There was a problem creating the venue.'
      flash_alert_now  @venue.errors.full_messages.to_sentence
      redirect_to new_venue_path
    else
      flash_notice 'The venue was successfully created'
      redirect_to venue_path(@venue)
    end
  end

  def edit
    @venue = Venue.find(params[:id])
  end

  def show
    @venue = Venue.find(params[:id])
  end

  def event_hotel
    @venue = EventHotel.first
  end

  def update
    @venue = Venue.find(params[:id])
    Rails.logger.debug(venue_params)
    Rails.logger.debug(event_hotel_params)
    if !@venue.update(venue_params)
      flash_alert_now 'There was a problem updating the venue information'
      flash_alert_now  @venue.errors.full_messages.to_sentence
      render action: :edit
    else
      @venues = Venue.all
      redirect_to venues_manage_path
    end
  end

  def update_event_hotel
    @event_hotel = EventHotel.find(params[:id])
    if !@event_hotel.update(event_hotel_params)
      flash_alert_now 'There was a problem updating the venue information'
      flash_alert_now  @venue.errors.full_messages.to_sentence
    end

    @venues = Venue.all
    redirect_to venues_manage_path
  end

  def manage
    @venues = get_objects "Venue"
  end

  def destroy
    @venue = Venue.find(params[:id])
    @venue.destroy
    redirect_to venues_manage_path
  end

  def destroy_all
    Venue.destroy_all
    redirect_to venues_manage_path
  end

  def import
    import_data "venues.csv", "Venue"
    redirect_to venues_manage_path
  end

  private
    def venue_params
      params.require(:venue).permit(
        :name,
        :event_hotel,
        :show_field_venue,
        :phone,
        :email,
        :website,
        :address,
        :details,
        :type
      )
    end

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
