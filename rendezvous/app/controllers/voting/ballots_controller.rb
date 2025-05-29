module Voting
  class BallotsController < ApplicationController
    
    layout 'ballot_layout', only: [:ballot]

    def ballot
      ballot_id = params[:ballot_id] || session[:ballot_id]
      unless ballot_id.nil?
        @ballot = Voting::Ballot.find(ballot_id)
        @ballot.get_status
        @ballot.save
        @selections = @ballot.categorized_selections
        @already_selected = already_selected?(@vehicle)
      else
        @ballot = Ballot.create(year: Date.current.year, status: 'voting')
        session[:ballot_id] = @ballot.id
        @selections = @ballot.categorized_selections
      end

      @code = params[:code]
      @vehicle = @code.nil? ? nil : Vehicle.find_by_qr_code(@code)
    end

    def vote
      @ballot = Voting::Ballot.find(params[:ballot_id])
      vehicle = Vehicle.find_by_qr_code(params[:code])

      if vehicle.nil? || @ballot.nil?
        # Handle error, possibly by rendering a proper error message or redirecting
        redirect_to @ballot, alert: 'Invalid ballot or vehicle.'
        return
      end

      vehicle.vote_by(@ballot)
      @ballot.save
      @selections = @ballot.categorized_selections
      redirect_to get_voting_ballot_path({ballot_id: @ballot.id, anchor: 'tabbed-2'})
    end

    def delete_selection
      @ballot = Voting::Ballot.find(params[:ballot_id])
      vehicle_id = params[:vehicle_id]
      @ballot.selections.delete(vehicle_id)
      @ballot.save
      @selections = @ballot.categorized_selections
      redirect_to get_voting_ballot_path({ballot_id: @ballot.id, anchor: 'tabbed-2'})
    end

    private
    def already_selected?(vehicle)
      @ballot.categorized_selections.values.any? { |vehicles| vehicles.include?(vehicle) }
    end
  end
end
