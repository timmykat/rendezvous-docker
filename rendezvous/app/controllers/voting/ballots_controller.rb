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
      @ballot = Voting::Ballot.find(params[:id])
      vehicle = Vehicle.find_by_qr_code(params[:code])

      if vehicle.nil? || @ballot.nil?
        # Handle error, possibly by rendering a proper error message or redirecting
        redirect_to ballot_path, alert: 'Invalid ballot or vehicle.'
        return
      end

      vehicle.vote_by(@ballot.user)
      @selections = @ballot.categorized_selections

      respond_to do |format|
        format.turbo_stream do
          if @selections.present?
            render turbo_stream: turbo_stream.update(
              "categories-content",
              partial: 'voting/ballots/selections',
              locals: { selections: @selections }
            )
            return
          end
        end
      end
      #     else
      #       Rails.logger.debug 'Oops, no selection' 
      #       render partial: "voting/ballots/selections", status: :unprocessable_entity, locals: { selections: @selections }
      #     end
      #   end
      #     format.html do
      #       if @selections.present? 
      #         render head :ok
      #       else
      #         render :ballot, status: :unprocessable_entity
      #       end
      #   end
      # end
    end
  end
end
