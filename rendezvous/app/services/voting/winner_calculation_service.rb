module Voting
  class WinnerCalculationService
    attr_reader :year, :tallies, :results, :favorite_of_show
  
    def initialize(year = Date.current.year)
      @year = year
      @tallies = Hash.new { |h, k| h[k] = Hash.new(0) } # category => { vehicle_id => count }
      @results = {} # category => { win: [], place: [], show: [] }
    end
  
    def calculate
      populate_tallies
      determine_podiums
      self
    end
  
    private
  
    def populate_tallies
      ballots = Ballot.where(year: year).where.not(status: "deciding")
  
      ballots.find_each do |ballot|
        ballot.selections.each do |vehicle|
          category = VehicleTaxonomy.get_category(vehicle)
          next unless category
  
          @tallies[category][vehicle.id] += 1
        end
      end
    end
  
    def determine_podiums
      @tallies.each do |category, vehicle_counts|
        next if vehicle_counts.empty?
  
        sorted_counts = vehicle_counts.group_by { |_, count| count }
                                       .sort_by { |count, _| -count }
                                       .to_a
  
        win_ids   = sorted_counts[0]&.last&.map(&:first) || []
        place_ids = sorted_counts[1]&.last&.map(&:first) || []
        show_ids  = sorted_counts[2]&.last&.map(&:first) || []
  
        @results[category] = {
          win:   Vehicle.where(id: win_ids),
          place: Vehicle.where(id: place_ids),
          show:  Vehicle.where(id: show_ids)
        }
      end

      # Calculate favorate of show (most votes across all categories)
      overall_votes = Hash.new(0) # vehicle_id => total_votes

      @tallies.each do |category, vehicle_counts|
        vehicle_counts.each do |vehicle_id, count|
          overall_votes[vehicle_id] += count
        end
      end

      # Find the maximum number of votes received
      max_votes = overall_votes.values.max

      # Select all vehicles that received the maximum number of votes
      favorites = overall_votes.select { |_, count| count == max_votes }.keys

      # Store the overall winner(s) as a separate instance variable
      if favorites.any?
        @favorite_of_show = Vehicle.where(id: favorites)
      end
    end
  end
end
  