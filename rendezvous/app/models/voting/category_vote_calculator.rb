module Voting
  class CategoryVoteCalculator
    attr_reader :year, :tallies, :results
  
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
        ballot.vehicles.each do |vehicle|
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
    end
  end
end
  