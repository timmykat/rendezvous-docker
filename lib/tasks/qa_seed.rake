require "#{Rails.root}/app/helpers/application_helper"
include ApplicationHelper

namespace :qa do
  desc "Seed the database for testing admin functions"
  task :seed => :environment do
    
    # Clear the database
    User.destroy_all
    RendezvousRegistration.destroy_all
    
    # Vehicle marque array
    vehicle_counts  = [0, 0, 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,3]
    vehicle_marques = ['Citroen','Citroen','Citroen','Citroen','Citroen','Citroen','Citroen','Citroen','Citroen','Panhard', 'Panhard', 'Peugeot', 'Maserati']
    
    # Load the admins
    Rake::Task['db:seed'].execute
    
    # Create the registrations, users, vehicles
    i = 0
    while i <= 150

      i += 1
      
      registration_params = {
        :year => '2016'
      }
      
      user_attributes = {
          :first_name         => "Pat-#{i}",
          :last_name          => "User-#{i}",
          :password           => "Rendezvous2016",
          :email              => "user#{i}@example.com",
          :address1           => "#{rand(3..2000)} Maple-#{i} Street",
          :city               => "City-#{i}",
          :state_or_province  => "XX",
          :postal_code        => "12345",
          :country            => ['US', 'CA'].sample
      }
      vehicles_attributes = []
      (vehicle_counts.sample).times.each do |v|
        marque = vehicle_marques.sample
        if marque == 'Citroen'
          model = Rails.configuration.rendezvous[:vehicle_models].sample
        else
          model = 'Some Model'
        end
        vehicle = {
          :marque => marque,
          :model  => model,
          :year   => '1963'
        }
        vehicles_attributes << vehicle
      end
      user_attributes[:vehicles_attributes] = vehicles_attributes
      
      registration_params[:user_attributes] = user_attributes
        
      num_adults =  [1,2,2,2,2,2,2,3].sample
      num_children = [0,0,0,0,0,0,0,0,1,2,2,2,3].sample
      sunday_dinner = [true, false, false, false, false].sample
      volunteer = [true, false, false, false, false, false, false, false, false, false].sample
      attendees_attributes = []
      num_adults.times.each do |a|
        attendee = {
          :name => "Lee Adult-Attendee-#{i}",
          :adult_or_child => 'adult',
          :sunday_dinner => sunday_dinner,
          :volunteer => volunteer
        }
        attendees_attributes << attendee
      end
      num_children.times.each do |a|
        attendee = {
          :name => "Lee Child-Attendee-#{i}",
          :adult_or_child => 'child',
          :sunday_dinner => sunday_dinner,
          :volunteer => volunteer
        }
        attendees_attributes << attendee
      end
          
      registration_params[:attendees_attributes] = attendees_attributes
      registration_params[:registration_fee] = num_adults * 50.0
      registration_params[:donation] = [0.0, 0.0, 0.0, 0.0, 25.0, 25.0, 50.0].sample 
      registration_params[:total] = registration_params[:registration_fee] + registration_params[:donation]
      registration_params[:paid_method] = ['credit card', 'credit card', 'credit card', 'check'].sample
      if registration_params[:paid_method] == 'credit card'
        registration_params[:paid_amount] = registration_params[:total]
        registration_params[:status] = 'complete'
      else
        registration_params[:paid_amount] = 0.0
        registration_params[:status] = 'payment due'
      end
      registration_params[:number_of_adults]    = num_adults
      registration_params[:number_of_children]  = num_children
      registration_params[:invoice_number]  = RendezvousRegistration.invoice_number
      
      r = RendezvousRegistration.new(registration_params)
      if !r.save
        puts registration_params[:invoice_number]
        puts r.errors.messages
      else
        puts "Creating #{i}\n"
      end
    end
  end
end