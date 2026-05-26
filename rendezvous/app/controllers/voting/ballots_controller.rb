module Voting
  class BallotsController < ApplicationController

    layout 'ballot_layout'

    before_action :require_admin, only: %i[new create]
    before_action :voting_on?, only: %i[show vote]

    before_action :set_ballot_count

    PER_CATEGORY_LIMIT = 1

    def set_ballot_count
      @ballot_count = Voting::Ballot.count
    end

    def voting_on?
      return if Config::SiteSetting.instance.voting_on

      flash_alert "People's Choice voting has not begun yet!"
      redirect_to :root
    end

    def new
      @ballot = Ballot.new
      @codes = []
      @number_of_categories = Vehicles::VehicleTaxonomy::VEHICLES[:marques].values.sum { |marque_data| marque_data[:categories].keys.count }
    end

    def create
      @ballot = Ballot.create(year: Date.current.year, status: 'hand_tally')
      params[:code].each do |code|
        vehicle = Vehicle.find_by_code(code)
        vehicle.vote_by(@ballot) unless vehicle.nil?
      end
      if @ballot.save
        flash_notice 'Ballot successfully counted'
      else
        flash_alert 'Something went wrong'
      end
      redirect_to create_ballot_path
    end

    def current
      if session[:ballot_id].present?
        ballot_id = session[:ballot_id]
        ballot = Voting::Ballot.find(ballot_id)
        return redirect_to voting_ballot_path(ballot) if ballot.present?
      end

      ballot = Voting::Ballot.create!(year: Date.current.year, status: 'voting')
      session[:ballot_id] = ballot.id
      redirect_to voting_ballot_path(ballot)
    end

    def landing
      if session[:ballot_id].present?
        @ballot = Voting::Ballot.find(session[:ballot_id])
      end

      if @ballot.present?
        @selections = @ballot.categorized_selections
        @ballot_data = @selections.to_json
      end
    end

    # Show this when a QR code shot is taken
    def preview
      if ((!params[:id].present? && !session[:ballot_id].present?)||!params[:code].present?)
        redirect_to landing_voting_ballot_path and return
      end

      if params[:id].present?
        @ballot = Voting::Ballot.find(params[:id])
      elsif session[:ballot_id]
        @ballot = Voting::Ballot.find(session[:ballot_id])
      end

      if @ballot.present?
        @selections = @ballot.categorized_selections
        @ballot_data = @selections.to_json
      end

      @vehicle = Vehicle.find_by_code(params[:code])
    end

    def selections
      if !params[:id].present? && !session[:ballot_id].present?
        redirect_to landing_voting_ballot_path and return
      end

      if params[:id].present?
        @ballot = Voting::Ballot.find(params[:id])
      elsif session[:ballot_id]
        @ballot = Voting::Ballot.find(session[:ballot_id])
      end

      return unless @ballot.present?

      @selections = @ballot.categorized_selections
      @ballot_data = @selections.to_json
    end

    def vote
      ballot = Voting::Ballot.find(params[:id])
      vehicle = Vehicle.find_by_code(params[:code])

      if vehicle.nil? || @ballot.nil?
        # Handle error, possibly by rendering a proper error message or redirecting
        redirect_to @ballot, alert: 'Invalid ballot or vehicle.'
        return
      end

      vehicle.vote_by(@ballot)
      ballot.save
      @selections = @ballot.categorized_selections
      @ballot_data = @selections.to_json
      redirect_to landing_voting_ballot_path(id: @ballot.id)
    end

    def delete_selection
      @ballot = Voting::Ballot.find(params[:id])
      vehicle_id = params[:vehicle_id]
      @ballot.selections.delete(vehicle_id)
      @ballot.save
      @selections = @ballot.categorized_selections
      redirect_to voting_ballot_path({ ballot_id: @ballot.id, code: nil, anchor: 'tabbed-2' })
    end

    private

    def already_selected?(vehicle)
      @ballot.categorized_selections.values.any? { |vehicles| vehicles.include?(vehicle) }
    end

    def limit_reached?(vehicle)
      category = vehicle.judging_category
      @selections[category].size >= PER_CATEGORY_LIMIT
    end
  end

  def ajax_info
    vehicle = Vehicle.find_by_code(params[:code])
    ballot = current_user.ballots.where(year: Date.current.year).first

    if vehicle.nil?
      data = { status: :not_found }
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
