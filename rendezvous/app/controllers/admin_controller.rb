require 'csv'
require 'fileutils'

class AdminController < ApplicationController

  layout "admin_layout"

  NO_USER_ID = 999999

  CSV_TYPES = {
    attendees: {
      headers: [
        'Registration number',
        'Registrant',
        'Attendee name',
        'Adult or child',
        'Volunteer?',
        'Donation?',
        'Date registration paid',
        ('As of: ' + Time.now.strftime('%Y%m%d'))
      ]
    },
    dash_placards: {
      headers: [
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
    }, 
    packet_labels: {
      headers: [
        'last_name',
        'guests',
        'people',
        'fee_status',
        'donation',
        'volunteers'
      ]
    },
    
    volunteers: {
      headers: [ 
        'Name', 
        'Email' 
      ]
    },
    winners: {
      headers: [
        'Category',
        'Owner',
        'Year',
        'Make',
        'Model'
      ]
    }
  }

  before_action :authenticate_user!
  before_action :require_admin
  before_action :calculate_annual_question

  def calculate_annual_question
    # @annual_question_data = {
    #   number: Event::Registration.current.group(:annual_answer).reverse.count,
    #   options: AnnualQuestion::RESPONSES.reverse
    # }

    @annual_question_data = {
      number: [15, 26, 43],
      options: AnnualQuestion::RESPONSES.reverse
    }
  end

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
      "2025" => "2025-06-13",
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
    
    if !params[:onsite_reg].blank?
      @onsite_reg = true
      render :index
      return
    end

    @annual_question = AnnualQuestion.where(year: Date.current.year).first
    @annual_responses = Event::Registration.where.not(annual_answer: nil).group(:annual_answer).count
    if !@annual_question
      @annual_question = AnnualQuestion.new
    end

    create_table_data
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
    when 'active'
      @users = User.where('last_active > ?', 10.minutes.ago)
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
    @volunteers = Attendee.joins(registration: :user).where(registrations: { year: 2025 }, volunteer: true).select('attendees.name AS name, users.email AS email')
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
      financials: {
        registration_fees: query.sum(:registration_fee),
        donations: query.sum(:donation),
        total: total_amount,
        paid: paid_amount,
        due: total_amount - paid_amount
      }
    }
  end

  def peoples_choice_results
    @results = Vehicle.top_3_by_category
  end

  def manage_qr_codes
    @vehicles = Vehicle.all
    @last_generated = "Not implemented"
  end

  def generate_qr_codes
    regenerate = params[:regenerate] == "true"
    if regenerate
      FileUtils.rm_rf(Dir.glob(Rails.root.join('public', 'qr_codes', '*')))
    end
    @vehicles = Vehicle.all
    @vehicles.each do |v|
      v.create_qr_code(regenerate)
    end
    redirect_to admin_manage_qr_codes_path
  end

  def print(item)
    case item
    when 'placards'
      @vehicles = Event::Registration.current.flat_map(&:vehicles)
      render :placards
      return
    when 'labels'
      @registrations = Event::Registration.current
      render :labels
      return
    when 'certificates'
      @winners = nil
      render :certificates
      return
    end
  end

  def download_csv
    type = CSV_TYPES.keys.include?(params[:type].to_sym) ? params[:type] : nil
    return if type.nil?

    respond_to do |format|
      format.csv do
        send_data get_csv_data(type), 
          filename: "#{type}-#{Date.current.strftime('%Y-%m-%d')}.csv", 
          type: "text/csv",
          disposition: 'attachment'
      end
    end
  end

  def get_csv_data(type)
    csv = CSV.generate(headers: true) do |csv_data|
      csv_data << CSV_TYPES[type.to_sym][:headers]
      Event::Registration.where(year: Date.current.year).all.each do |r|
        case type
          when 'attendees'
            r.attendees do |a|
              csv_data << [
                r.invoice_number,
                r.user.last_name_first,
                a.name,
                a.attendee_age.titlecase,
                (a.volunteer? ? 'Yes' : 'No'),
                # (a.sunday_dinner? ? 'Yes' : 'No'),
                (!r.donation.blank? && (r.donation.to_f > 0.0)) ? 'Yes' : 'No',
                r.paid_date
              ]
            end
            break

          when 'dash_placards'
            r.vehicles.each_with_index do |v, index|
              csv_data << [
                "#{r.invoice_number}-#{(index + 1).to_s}",
                r.user.last_name,
                r.user.first_name,
                r.user.full_name,
                v.year,
                v.marque,
                v.model,
                v.judging_category,
                v.other_info
              ]
            end
            break

          when 'packet_labels'
            csv_data << [
              "#{r.user.last_name}",
              r.attendees.count,
              r.attendees.map{ |a| a.name }.join('<br>'),
              r.outstanding_balance? ? r.registration_fee : 'paid',
              (r.donation && (r.donation > 0.0)) ? r.donation : '',
              get_volunteers(r)
            ]
            break

          when 'volunteers'
            r.attendees do |a|
              if a.volunteer?
                csv_data << [
                  a.name, 
                  registration.user.email
                ]
              end
            end
            break
        end
      end
    end
    return csv
  end
end
