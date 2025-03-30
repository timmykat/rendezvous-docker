module ScheduledEventHelper
  def day_options
    ['Thursday', 'Friday', 'Saturday', 'Sunday']
  end

  def venue_options
    Venue.all.collect { |venue| [venue.name, venue.id] }
  end

  def main_event_options
    ScheduledEvent.where(has_subevents: true).collect { |event| [event.name, event.id] }
  end
end
