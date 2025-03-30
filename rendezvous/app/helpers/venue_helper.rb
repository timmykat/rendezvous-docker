module VenueHelper

  def formatted_event_hotel
    venue = EventHotel.first
    [venue.name, venue.phone, venue.as_html(:address)].join('<br>').html_safe
  end

  def reservation_url
    venue = EventHotel.first
    Rails.logger.debug "Rezzy link: #{venue.reservation_url}"
    venue.reservation_url
  end
end
