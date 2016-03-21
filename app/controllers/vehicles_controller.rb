class VehiclesController < ApplicationController
  before_action :authenticate_user!

  def my_vehicles
    @vehicles = current_user.vehicles.all
  end

end