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
        @selections = @ballot.categorized_selections
      end
    end

    def vote
      @ballot = Voting::Ballot.find(params[:id])
      vehicle = Vehicle.find_by_qr_code(params[:code])

      if vehicle.nil? || ballot.nil?
        # Handle error, possibly by rendering a proper error message or redirecting
        render ballot_path, alert: 'Invalid ballot or vehicle.'
        return
      end

      vehicle.vote_by(@ballot.user)
      @selections = @ballot.categorized_selections

      Rails.logger.debug @selections

      respond_to do |format|
        format.turbo_stream do
          turbo_stream_response = render_to_string(
            turbo_stream: turbo_stream.replace(
              "categories-content",
              partial: 'voting/ballots/selections',
              locals: { selections: @selections }
            ))
          Rails.logger.debug "*****"
          Rails.logger.debug turbo_stream_response
          Rails.logger.debug "*****"
          render turbo_stream: turbo_stream.replace(
            "categories-content",
            partial: 'voting/ballots/selections',
            locals: { selections: @selections }
          )
          return
        end
        format.html { head :ok }
      end
    end

    private
      def categorize_selections(selections)
        selections.group_by(&:category)
      end
  end
end
