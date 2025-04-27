module Voting
  class BallotsController < ApplicationController
    include ::Turbo::StreamsHelper
    
    layout 'ballot_layout'

    before_action :authenticate_user!, { only: [:ballot] }

    def ballot
      if params[:id].present?
        @ballot = Voting::Ballot.find(params[:id])
        @ballot.get_status
        @ballot.save
      else
        @ballot = Voting::Ballot.where(year: Date.current.year).where(user: current_user).first
        if !@ballot.present?
          @ballot = Voting::Ballot.create(year: Date.current.year, user: current_user, status: 'voting')
        end
        @selections = @ballot.categorized_selections
      end
    end

    def vote
      @ballot = Voting::Ballot.find(params[:ballot_id])
      vehicle = Vehicle.find_by_qr_code(params[:code])

      if vehicle.nil? || @ballot.nil?
        # Handle error, possibly by rendering a proper error message or redirecting
        redirect_to @balloth, alert: 'Invalid ballot or vehicle.'
        return
      end

      vehicle.vote_by(@ballot.user)
      @selections = @ballot.categorized_selections

      respond_to do |format|
        format.turbo_stream
        format.html { head :no_content }
      end
      return
    end

    def delete_selection
      @ballot = Voting::Ballot.find(params[:ballot_id])
      vehicle_id = params[:vehicle_id]
      @ballot.selections.delete(vehicle_id)
      @ballot.save
      @selections = @ballot.categorized_selections

      respond_to do |format|
        format.turbo_stream
        format.html { head :no_content }
      end
      return
    end
  end
end
