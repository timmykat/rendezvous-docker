module VenuesHelper
  def sti_options
    [["Standard Venue", nil], ["Event Hotel", "Admin::EventHotel"]]
  end
end