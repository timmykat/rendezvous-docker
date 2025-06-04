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

  def ajax_info
    vehicle = Vehicle.find_by_code(params[:code])
    ballot = current_user.ballots.where(year: Date.current.year).first

    if vehicle.nil?
      data = { status: 'not found'}
    else
      
      if ballot.selections.include? vehicle
        data = { errorInfo: '<div class="selection">You\'ve already voted for that one!</div>', status: 'already selected' }
      end

      if data.nil? 
        category = vehicle.judging_category 
        categorized_selections = ballot.categorized_selections
        if categorized_selections[category].length == 3
          data = { errorInfo:  '<div class="selection">You\'ve reached your max in that category.</div>', status: 'maxed out'}
        else 
          data = { vehicleInfo: vehicle.voting_info_format, status: 'found' }
        end
      end
    end

    respond_to do |format|
      format.json do
        render json: data
      end
    end
  end
end