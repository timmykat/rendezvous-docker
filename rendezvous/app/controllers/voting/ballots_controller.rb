module Voting
  class BallotsController < ApplicationController
    
    layout 'ballot_layout', only: [:ballot]

    def ballot
      @code = params[:code]
      @vehicle = Vehicle.find_by_qr_code(@code)

      if params[:ballot_id].present?
        @ballot = Voting::Ballot.find(params[:ballot_id])
        @ballot.get_status
        @ballot.save
        @selections = @ballot.categorized_selections
        @already_selected = already_selected?(@vehicle)
      else
        @ballot = Ballot.create(year: Date.current.year, status: 'voting')
        session[:ballot_id] = @ballot.id
        @selections = @ballot.categorized_selections
      end
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
      redirect_to get_voting_ballot_path(@ballot, anchor: 'tabbed-2')
    end

    def delete_selection
      @ballot = Voting::Ballot.find(params[:ballot_id])
      vehicle_id = params[:vehicle_id]
      @ballot.selections.delete(vehicle_id)
      @ballot.save
      @selections = @ballot.categorized_selections

      respond_to do |format|
        format.turbo_stream { render layout: false }
        format.html { head :no_content }
      end
      return
    end

    private
    def already_selected?(vehicle)
      @ballot.categorized_selections.values.any? { |vehicles| vehicles.include?(vehicle) }
    end
  end
end
