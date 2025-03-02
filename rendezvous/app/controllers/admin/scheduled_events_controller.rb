class Admin::ScheduledEventsController < AdminController
  
  def index
    @venues = Admin::ScheduledEvent.all
  end

  def new
    @scheduled_event = Admin::ScheduledEvent.new
  end

  def create
    @scheduled_event = Admin::ScheduledEvent.new(scheduled_event_params)
    if !@scheduled_event.save
      flash_alert_now 'There was a problem creating the scheduled event.'
      flash_alert_now  @scheduled_event.errors.full_messages.to_sentence
      redirect_to new_admin_scheduled_event_path
    else
      flash_notice 'The FAQ was successfully created'
    end
  end

  def show
    @scheduled_event = Admin::ScheduledEvent.find(params[:id])
  end

  def update
    @scheduled_event = Admin::ScheduledEvent.find(params[:id])
    if !@scheduled_event.update(scheduled_event_params)
      flash_alert_now 'There was a problem updating the scheduled event information'
      flash_alert_now  @scheduled_event.errors.full_messages.to_sentence
      render action: :edit
    else
      redirect_to admin_scheduled_event_path(@scheduled_event)
    end
  end

  private
    def scheduled_event_params
      params.require(:admin_scheduled_event).permit(
        :name,
        :day,
        :time,
        :short_description,
        :long_description,
        :order,
        :admin_venue
      )
    end
end
