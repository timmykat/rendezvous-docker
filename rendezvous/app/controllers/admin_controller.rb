require 'csv'

class AdminController < ApplicationController

  layout "admin_layout"

  NO_USER_ID = 999999

  before_action :require_admin

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

  def dashboard(csv = false)
    @title = 'Admin'
    @year = params[:year] || Date.current.year
    @no_user_id = NO_USER_ID
    @csvs = {
      'labels' => 'Packet Label Data',
      'registered_users' => 'Registered Users',
      'attendees'  => 'Attendee Data',
      'volunteers'    => 'Volunteer List',
      'vehicles'      => 'Vehicle Manifest'
    }
    
    if !params[:onsite_reg].blank?
      @onsite_reg = true
      render :index
      return
    end

    @annual_question = AnnualQuestion.where(year: Date.current.year).first
    if !@annual_question
      @annual_question = AnnualQuestion.new
    end

    create_table_data

    if params[:create_csv]
      create_csvs
    end
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

  def create_table_data
    query = Event::Registration.where(year: @year)
    @event_registrations = query.all
    case (params[:user_type])
    when 'all_users'
      @users = User.all
      @type = 'All users'
    when 'registrant'
      @users = User.with_registrations
      @type = 'Any Registrant'
    when 'testers'
      @users = User.with_role :tester
      @type = 'Site Testers'
    when 'vendors'
      @users = User.with_role :vendor
      @type = 'Vendors'
    else 
      @users = User.with_current_registration
      @type = 'Currently registered'
    end
    @user_count = @users.nil? ? 0 : @users.pluck(:id, :last_name).count

    @vehicles = Vehicle.joins(:registrations).where(registrations: { year: @year })
    volunteers = query.joins(:attendees).select(:name).where(attendees: { volunteer: true })
    total_amount = query.sum(:total)
    paid_amount = query.sum(:paid_amount)
    @data = {
      registrants: User.joins(:registrations).where(registrations: { year: @year }),
      citroens: query.joins(:vehicles).where(vehicles: { marque: "Citroen" }),
      non_citroens: query.joins(:vehicles).where.not(vehicles: { marque: "Citroen" }),
      attendees: query.joins(:attendees).count,
      newbies: [],
      adult: query.joins(:attendees).where(attendees: { attendee_age: 'adult'}).count,
      child: query.joins(:attendees).where(attendees: { attendee_age: 'child'}).count,
      volunteers: {
        number: volunteers.length,
        list: volunteers,
      },
      financials: {
        registration_fees: query.sum(:registration_fee),
        donations: query.sum(:donation),
        total: total_amount,
        paid: paid_amount,
        due: total_amount - paid_amount
      }
    }
  end

  def create_csvs
    @event_registrations = Event::Registration.where(year: @year).all if @event_registrations.nil?

    # Create CSV data files
    files = {}
    csv_file = {}
    csv_data = {}
    
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
      files[data_type] = {
        'name'        => file_name,
        'path'        => File.join(Rails.root, 'public', helpers.static_file("csv/#{file_name}")),
        'descriptor'  => descriptor
      }
      if system("mkdir -p #{File.dirname(files[data_type]['path'])}")
        csv_file[data_type] = File.new(files[data_type]['path'], 'wb')
        csv_data[data_type] = ::CSV.new(csv_file[data_type])
      end
    end

    # CSV file headers
    csv_data['labels'] << [
      'last_name',
      'guests',
      'people',
      'fee_status',
      'donation',
      'volunteers'
    ]
    csv_data['registered_users'] << [
      'full name',
      'email',
      'address',
      'volunteers'
    ]
    csv_data['attendees'] << [
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
    csv_data['volunteers'] << [ 'Name', 'Email' ]
    csv_data['vehicles'] << [
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

    @event_registrations.each do |registration|
      csv_data['labels'] << [
        "#{registration.user.last_name}",
        registration.attendees.count,
        registration.attendees.map{ |a| a.name }.join('<br>'),
        registration.outstanding_balance? ? registration.registration_fee : 'paid',
        (registration.donation && (registration.donation > 0.0)) ? registration.donation : '',
        get_volunteers(registration)
      ]

      csv_data['registered_users'] << [
        registration.user.full_name,
        registration.user.email,
        helpers.address_of_plain(registration.user),
        get_volunteers(registration)       
      ]

      nvehicle = 0
      registration.user.vehicles.each do |v|
        nvehicle += 1
        csv_data['vehicles'] << [
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
        csv_data['attendees'] << [
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
          csv_data['volunteers'] << [ a.name, registration.user.email ]
        end
      end
    end
    flash_notice "New CSVs created"
  end
end
