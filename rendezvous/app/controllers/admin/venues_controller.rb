class Admin::VenuesController < AdminController

  def index
    @venues = Admin::Venue.all
  end
  
  def new
    @venue = Admin::Venue.new
    puts @venue
    @venue
  end

  def create
    @venue = Admin::Venue.new(venue_params)
    if !@venue.save
      flash_alert_now 'There was a problem creating the venue.'
      flash_alert_now  @venue.errors.full_messages.to_sentence
      redirect_to new_admin_venue_path
    else
      flash_notice 'The FAQ was successfully created'
      redirect_to admin_venue_path(@venue)
    end
  end

  def show
    @venue = Admin::Venue.find(params[:id])
  end

  def update
    @venue = Admin::Venue.find(params[:id])
    if !@venue.update(venue_params)
      flash_alert_now 'There was a problem updating the venue information'
      flash_alert_now  @venue.errors.full_messages.to_sentence
      render action: :edit
    else
      redirect_to admin_venue_path(@venue)
    end
  end

  private
    def venue_params
      params.require(:admin_venue).permit(
        :name,
        :event_hotel,
        :show_field_venue,
        :phone,
        :email,
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
