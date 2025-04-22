module Voting
  class BallotsController < ApplicationController
    include ::Turbo::StreamsHelper
    
    layout 'ballot_layout'

    before_action :authenticate_user!

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
      end
    end

    def vote
      ballot = Voting::Ballot.find(params[:id])
      Rails.logger.debug ballot
      vehicle = Vehicle.find_by_qr_code(params[:code])
      Rails.logger.debug vehicle
      Rails.logger.debug ballot.user
      vehicle.vote_by(ballot.user)
  
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "#accordion-content",
            partial: 'voting/ballots/accordion_view',
            locals: { categorized_selections: [] } #ballot.categorized_selections }
          )
        end
      end
    end
  end
end
