module VenuesHelper
  def sti_options
    [["Standard Venue", nil], ["Event Hotel", "EventHotel"]]
  end

  def format_for_schedule(venue)
    "<strong>#{venue.name}, #{short_address(venue.address)}</strong>"
  end

  def short_address address
    address_lines = address.gsub("\\", '').split("\n")
    "#{address_lines[0]}, #{address_lines[1].split(",")[0]}"
  end

end