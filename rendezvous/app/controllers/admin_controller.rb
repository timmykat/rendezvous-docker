require 'csv'

class AdminController < ApplicationController
  before_action :require_admin, :get_data

  def get_data
    @year = params[:year] || Time.now.year
    @event_registrations = Event::Registration.alpha.where("year = ?", @year)
    @users = User.order(last_name: :asc).all
  end

  def index
    @title = 'Admin'

    # Create CSV data files
    @files = {}
    csv_file = {}
    csv_object = {}
    data_types = {
      'labels' => 'Packet Label Data',
      'registrations'  => 'Attendee Data',
      'volunteers'    => 'Volunteer List',
      # 'sunday_dinner' => 'Sunday Dinner List',
      'vehicles'      => 'Vehicle Manifest'
    }
   data_types.each do |data_type, descriptor|
      file_name = "#{data_type}_data.csv"
      @files[data_type] = {
        'name'        => file_name,
        'path'        => File.join(Rails.root, 'public', helpers.static_file("csv/#{file_name}")),
        'descriptor'  => descriptor
      }
      csv_file[data_type] = File.new(@files[data_type]['path'], 'wb')
      csv_object[data_type] = ::CSV.new(csv_file[data_type])
    end

   # CSV file headers
   csv_object['labels'] <<[
    'Registratant Name',
    'Guests',
    'Fee Status',
    'Donation',
    'Volunteers',
    'Vehicles'
   ]
    csv_object['registrations'] << [
      'Registration number',
      'Registratant',
      'Attendee name',
      'Adult, senior (80+) or child',
      'Volunteer?',
      # 'Sunday dinner?',
      'Donation?',
      'Date registration paid',
      ('As of: ' + Time.now.strftime('%Y%m%d'))
    ]

    csv_object['volunteers'] << [ 'Name', 'Email' ]

    # csv_object['sunday_dinner'] << [ 'Name', 'Email' ]

    csv_object['vehicles'] << [
      'Number',
      'Registrant Last Name',
      'Registrant First Name',
      'Registrant Full Name',
      'Year',
      'Marque',
      'Model',
      'Info'
    ]

    @data = {
      registrants: [],
      citroens: [],
      non_citroens: [],
      attendees: [],
      newbies: [],
      adult: 0,
      senior: 0,
      child: 0,
      # sunday_dinner: {
      #   number: 0,
      #   list: [],
      # },
      volunteers: {
        number: 0,
        list: [],
      },
      financials: {
        registration_fees: 0.0,
        donations: 0.0,
        total: 0.0,
        paid: 0.0,
        due: 0.0
      }
    }
    @event_registrations.each do |registration|
      @data[:registrants] << registration.user
      @data[:newbies] << registration.user if registration.user.newbie?
      @data[:financials][:total]                += registration.total.to_f unless registration.total.blank?
      @data[:financials][:registration_fees]    += registration.registration_fee.to_f unless registration.registration_fee.blank?
      @data[:financials][:paid]                 += registration.paid_amount.to_f unless registration.paid_amount.blank?
      @data[:financials][:due]                  += registration.balance.to_f unless registration.balance.blank?
      @data[:financials][:donations]            += registration.donation.to_f unless registration.donation.blank?

      csv_object['labels'] << [
        "#{registration.user.last_name}, #{registration.user.first_name}",
        registration.attendees.count,
        registration.paid? ? 'PAID' : "$#{registration.registration_fee}",
        (registration.donation && registration.donation) > 0.0 ? "Donation: $#{registration.donation}" : '',
        "Volunteers: #{get_volunteers(registration)}"
      ]
      nvehicle = 0
      registration.user.vehicles.each do |v|
         if v.marque == 'Citroen'
          @data[:citroens]      << v
        else
          @data[:non_citroens]  << v
        end

        nvehicle += 1
        csv_object['vehicles'] << [
          "#{registration.invoice_number}-#{nvehicle.to_s}",
          registration.user.last_name,
          registration.user.first_name,
          registration.user.full_name,
          v.year,
          v.marque,
          v.model,
          v.other_info
        ]
      end

      registration.attendees.each do |a|
        @data[:attendees] << a.name
        @data[a.attendee_age.to_sym]  += 1
        # if a.sunday_dinner?
        #   @data[:sunday_dinner][:number]            += 1
        #   @data[:sunday_dinner][:list] << { name: a.name, email:  registration.user.email }
        # end
        if a.volunteer?
          @data[:volunteers][:number]               += 1
          @data[:volunteers][:list] << { name: a.name, email:  registration.user.email }
        end

        #Write to CSV
        # Registered attendees
        csv_object['registrations'] << [
          registration.invoice_number,
          registration.user.last_name_first,
          a.name,
          a.attendee_age.titlecase,
          (a.volunteer? ? 'Yes' : 'No'),
          # (a.sunday_dinner? ? 'Yes' : 'No'),
          (!registration.donation.blank? && (registration.donation.to_f > 0.0)) ? 'Yes' : 'No',
          registration.paid_date
        ]

        # Volunteers
        if a.volunteer?
          csv_object['volunteers'] << [ a.name, registration.user.email ]
        end

        # Sunday dinner
        # if a.sunday_dinner?
        #   csv_object['sunday_dinner'] << [ a.name, registration.user.email ]
        # end

      end
    end

    @vehicles = @data[:citroens] + @data[:non_citroens]
  end

  def toggle_user_session
    session[:admin_user] = !session[:admin_user]
    redirect_back(fallback_location: root_path)
  end

  def get_volunteers(registration)
    volunteers = 0
    registration.attendees.each do |a|
      volunteers += 1 if a.volunteer?
    end
    return volunteers
  end
end
