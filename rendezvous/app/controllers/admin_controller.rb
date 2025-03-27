require 'csv'

class AdminController < ApplicationController

  layout "admin"

  NO_USER_ID = 999999

  before_action :require_admin
  before_action :get_data, { only: :dashboard }

  def dedupe
    notice = []
    {
        KeyedContent => :key, 
        ScheduledEvent => :name, 
        Vendor => :name, 
        Venue => :name}.each do |klass, attrib|
      instances = klass.all
      dupes_deleted = 0
      klass_name = klass.to_s
      instances.group_by(&attrib).each do |name, group|
        group[1..-1].each do |inst|
          inst.destroy
          dupes_deleted += 1
        end
      end
      notice << "Number of #{klass_name} deleted: #{dupes_deleted.to_s}"
    end
    flash_notice notice.join("<br>\n")
    redirect_to admin_dashboard_path
  end

  def get_data
    @year = params[:year] || Time.now.year
    @event_registrations = Event::Registration.alpha.where("year = ?", @year)
    @users = User.order(last_name: :asc).all
  end

  def registration_graphs
    @title = 'Registration Income Graphs'
    event_dates = {
      "2016" => "2016-06-16",
      "2017" => "2017-06-15",
      "2018" => "2018-06-14",
      "2019" => "2019-06-13",
      "2021" => "2021-09-09",
      "2022" => "2022-06-16",
      "2023" => "2023-06-30",
      "2024" => "2024-06-14",
    }

    rendezvous_years = Event::Registration.group(:year).pluck(:year).sort.reverse

    reg_data = {}
    rendezvous_years.each do |year|
      event_date = DateTime.strptime(event_dates[year], "%Y-%m-%d")
      reg_data[year.to_s] = []
      registrations = Event::Registration.where(year: year).order(:updated_at).all
      total = 0
      date = nil
      (0..90).to_a.reverse.each do |d|
        registrations.each do |r|
          date = r.updated_at.strftime("%F")
          date_diff = (event_date.to_date - r.updated_at.to_date).to_i
          if date_diff == d
            total = total + r.paid_amount if r.status == 'complete'
          end
        end
        reg_data[year.to_s] << { daysOut: d, total: total }
      end
      @reg_data = reg_data.to_json
      @event_dates = event_dates.to_json
      @xLabels = (90).step(by: -1, to: 0).to_a.to_json
    end
  end

  def dashboard
    @title = 'Admin'
    @no_user_id = NO_USER_ID
    
    if !params[:onsite_reg].blank?
      @onsite_reg = true
      render :index
      return
    end

    # Create CSV data files
    @files = {}
    csv_file = {}
    csv_object = {}
    data_types = {
      'labels' => 'Packet Label Data',
      'registered_users' => 'Registered Users',
      'attendees'  => 'Attendee Data',
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
      if system("mkdir -p #{File.dirname(@files[data_type]['path'])}")
        csv_file[data_type] = File.new(@files[data_type]['path'], 'wb')
        csv_object[data_type] = ::CSV.new(csv_file[data_type])
      end
    end

   # CSV file headers
   csv_object['labels'] <<[
    'last_name',
    'guests',
    'people',
    'fee_status',
    'donation',
    'volunteers'
    ]

    csv_object['registered_users'] << [
      'full name',
      'email',
      'address',
      'volunteers'
    ]

    csv_object['attendees'] << [
      'Registration number',
      'Registratant',
      'Attendee name',
      'Adult or child',
      'Volunteer?',
      # 'Sunday dinner?',
      'Donation?',
      'Date registration paid',
      ('As of: ' + Time.now.strftime('%Y%m%d'))
    ]

    csv_object['volunteers'] << [ 'Name', 'Email' ]

    # csv_object['sunday_dinner'] << [ 'Name', 'Email' ]

    csv_object['vehicles'] << [
      'number',
      'last_name',
      'first_name',
      'full_name',
      'year',
      'marque',
      'model',
      'category',
      'info'
    ]

    @data = {
      registrants: [],
      citroens: [],
      non_citroens: [],
      attendees: [],
      newbies: [],
      adult: 0,
      child: 0,
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
        "#{registration.user.last_name}",
        registration.attendees.count,
        registration.attendees.map{ |a| a.name }.join('<br>'),
        registration.outstanding_balance? ? registration.registration_fee : 'paid',
        (registration.donation && (registration.donation > 0.0)) ? registration.donation : '',
        get_volunteers(registration)
      ]

      csv_object['registered_users'] << [
        registration.user.full_name,
        registration.user.email,
        helpers.address_of_plain(registration.user),
        get_volunteers(registration)       
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
          v.judging_category,
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
        csv_object['attendees'] << [
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

  def make_labels
    @labels = []
    Event::Registration.alpha.where("year = ?", @year).each do |r|
      label = {}
      label['name'] = "#{r.user.last_name}, #{r.user.first_name}"
      label['people'] = r.attendees.count
      label['fee'] = r.outstanding_balance? ? 'PAID' : "Due: $#{r.registration_fee.to_i}"
      label['donation'] = (r.donation && (r.donation > 0.0)) ? r.donation.to_i : 0
      label['volunteers'] = get_volunteers(r)

      @labels << label
    end
    render layout: 'no_header', template: 'admin/labels'
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
