class ScheduledEventsController < AdminController
  
  def new
    @scheduled_event = ScheduledEvent.new
  end

  def create
    @scheduled_event = ScheduledEvent.new(scheduled_event_params)
    if !@scheduled_event.save
      flash_alert_now 'There was a problem creating the scheduled event.'
      flash_alert_now  @scheduled_event.errors.full_messages.to_sentence
      redirect_to new_scheduled_event_path
    else
      flash_notice 'The FAQ was successfully created'
    end
  end

  def show
    @scheduled_event = ScheduledEvent.find(params[:id])
  end

  def update
    Rails.logger.debug(scheduled_event_params)
    @scheduled_event = ScheduledEvent.find(params[:id])
    Rails.logger.debug(@scheduled_event)
    if !@scheduled_event.update(scheduled_event_params)
      flash_alert_now 'There was a problem updating the scheduled event information'
      flash_alert_now  @scheduled_event.errors.full_messages.to_sentence
      render action: :edit
    else
      flash_alert_now "The event #{@scheduled_event.name} was updated"
      @scheduled_events = ScheduledEvent.sorted
      redirect_to scheduled_events_manage_path
    end
  end

  def manage
    @scheduled_events = get_objects "ScheduledEvent"
  end

  def destroy
    @scheduled_events = ScheduledEvent.find(params[:id])
    @scheduled_events.destroy
    redirect_to scheduled_events_manage_path
  end

  def destroy_all
    ScheduledEvent.destroy_all
    redirect_to scheduled_events_manage_path
  end

  def import
    import_data "scheduled_events.csv", "ScheduledEvent"
    redirect_to scheduled_events_manage_path
  end

  private
    def scheduled_event_params
      params.require(:scheduled_event).permit(
        :name,
        :day,
        :has_subevents,
        :time,
        :short_description,
        :long_description,
        :order,
        :venue_id,
        :main_event_id
      )
    end
end
