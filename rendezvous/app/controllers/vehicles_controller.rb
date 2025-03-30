class VehiclesController < ApplicationController
  before_action :authenticate_user!, { only: [:my_vehicles] }

  def my_vehicles
    @vehicles = current_user.vehicles.all
  end

  def for_sale
    @vehicles = Vehicle.joins(:registrations)
      .merge(Event::Registration.current)
      .where(for_sale: true)
      .distinct
  end

end