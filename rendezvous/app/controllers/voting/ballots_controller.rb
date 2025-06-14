module Voting
  class BallotsController < ApplicationController
    
    layout 'ballot_layout', only: [:ballot, :hand_ballot]

    before_action :require_admin, only: [:hand_ballot, :hand_count]
    before_action :voting_on?, only: [:ballot, :vote]

    PER_CATEGORY_LIMIT = 3

    def voting_on?
      return if Config::SiteSetting.instance.voting_on

      flash_alert "People's Choice voting has not begun yet!"
      redirect_to :root
    end

    def hand_ballot
      @ballot = Ballot.new
      @codes = []
      @number_of_categories = VehicleTaxonomy::VEHICLES[:marques].values.sum { |marque_data| marque_data[:categories].keys.count }
    end

    def hand_count
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
      redirect_to voting_hand_ballot_path
    end

    def ballot
      ballot_id = params[:ballot_id] || session[:ballot_id]
      if ballot_id.nil?
        @ballot = Ballot.create(year: Date.current.year, status: 'voting')
      end

      @ballot = Voting::Ballot.find(ballot_id)
      @code = params[:code]
      if @code.present?
        @vehicle = Vehicle.find_by_code(@code)
      end

      if @vehicle.nil?
        redirect_to get_voting_ballot_url, alert: 'Invalid ballot or vehicle.'
        return
      end        
    
      @selections = @ballot.categorized_selections

      if @vehicle.present?
        @category = @vehicle.judging_category
        @already_selected = already_selected?(@vehicle)
        @limit_reached = limit_reached?(@vehicle)
      end
    end

    def vote
      @ballot = Voting::Ballot.find(params[:ballot_id])
      vehicle = Vehicle.find_by_code(params[:code])

      if vehicle.nil? || @ballot.nil?
        # Handle error, possibly by rendering a proper error message or redirecting
        redirect_to @ballot, alert: 'Invalid ballot or vehicle.'
        return
      end

      vehicle.vote_by(@ballot)
      @ballot.save
      @selections = @ballot.categorized_selections
      redirect_to get_voting_ballot_path({ballot_id: @ballot.id, code: nil, anchor: 'tabbed-2'})
    end

    def delete_selection
      @ballot = Voting::Ballot.find(params[:ballot_id])
      vehicle_id = params[:vehicle_id]
      @ballot.selections.delete(vehicle_id)
      @ballot.save
      @selections = @ballot.categorized_selections
      redirect_to get_voting_ballot_path({ballot_id: @ballot.id, code: nil, anchor: 'tabbed-2'})
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
end
