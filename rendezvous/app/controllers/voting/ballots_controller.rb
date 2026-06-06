module Voting
  class BallotsController < ApplicationController

    layout 'ballot_layout'

    before_action :require_admin, only: %i[new create index]
    before_action :ensure_voting_is_on, only: %i[new landing vote]

    before_action :set_current_ballot, only: %i[landing selections vote delete_selection]

    PER_CATEGORY_LIMIT = 1

    def index
      @ballots = Ballot.order(year: :desc)
    end

    def ensure_voting_is_on?
      return if Config::SiteSetting.instance.voting_on?

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

    def landing

      create_js_data
    end

    def selections
      redirect_to landing_voting_ballots_path(anchor: 'selections')
    end

    def vote
      unless params[:code].present?
        redirect_to landing_voting_ballots_path, alert: 'No voting code available!'
        return
      end

      vehicle = Vehicle.find_by_code(params[:code])

      if vehicle.nil?
        redirect_to landing_voting_ballots_path, alert: 'No vehicle for that code!'
        return
      end

      if limit_reached?(vehicle)
        category = vehicle.judging_category
        redirect_to landing_voting_ballots_path(anchor: 'selections'),
                    alert: "You must delete your current <em>#{category}</em> selection".html_safe
        return
      end

      vehicle.vote_by(@ballot)
      @ballot.save
      redirect_to landing_voting_ballots_path(anchor: 'selections')
    end

    def delete_selection
      vehicle_id = params[:vehicle_id]
      return unless vehicle_id.present?

      @ballot.selections.delete(vehicle_id)
      @ballot.save
      redirect_to landing_voting_ballots_path({ code: nil, anchor: 'selections' })
    end

    def create_js_data

      @selections = @ballot.categorized_selections
      @ballot_data = @selections
      @selected_codes = @ballot_data.values.flat_map { |vehicles| vehicles.map(&:code) }
    end

    private

    def set_current_ballot
      @ballot = Voting::Ballot.find_by_id(session[:ballot_id])
      return if @ballot.present?

      @ballot = Voting::Ballot.new(status: 'voting')
      unless @ballot.save
        redirect_to root_path, alert: 'Could not create ballot.'
        return
      end

      session[:ballot_id] = @ballot.id
    end

    def already_selected?(vehicle)
      @ballot.categorized_selections.values.any? { |vehicles| vehicles.include?(vehicle) }
    end

    def limit_reached?(vehicle)
      @selections = @ballot.categorized_selections
      category = vehicle.judging_category
      @selections[category].to_a.size >= PER_CATEGORY_LIMIT
    end
  end
end
