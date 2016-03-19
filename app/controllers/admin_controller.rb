class AdminController < ApplicationController
  before_action :require_admin
  
  def index
    @registrations = RendezvousRegistration.where(:year => Time.now.year)
    
    @data = {
      :registrants    => [],
      :citroens       => [],
      :non_citroens   => [],
      :attendees      => [],
      :adult          => 0,
      :child          => 0,
      :sunday_dinner  => 0,
      :volunteer      => 0
    }
    @registrations.each do |registration|
      @data[:registrants] << registration.user
      
      registration.user.vehicles.each do |v|
        if v.marque == 'Citroen'
          @data[:citroens]      << v
        else
          @data[:non_citroens]  << v
        end
      end
      
      registration.attendees.each do |a|
        @data[:attendees] << a.name
        @data[a.adult_or_child.to_sym]  += 1
        @data[:sunday_dinner]           += 1  if a.sunday_dinner?
        @data[:volunteer]               += 1  if a.volunteer?        
      end
    end
    
    @vehicles = @data[:citroens] + @data[:non_citroens]
  end
end
