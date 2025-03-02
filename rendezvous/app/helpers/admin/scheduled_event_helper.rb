module Admin::ScheduledEventHelper
  def day_options
    options_for_select(['Thursday', 'Friday', 'Saturday', 'Sunday'])
  end

  def venue_options
    options_for_select(Admin::Venue.all.map{ |x| [v.name, v.id] })
  end
end
