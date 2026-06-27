require 'csv'
require 'fileutils'

module Admin
  class AdminController < ApplicationController

    layout :select_layout

    NO_USER_ID = 999999

    CSV_TYPES = {
      registrants: {
        headers: [
          'Registrant',
          'E-mail',
          'Guests',
          'Cruise count',
          'Sunday lunch count',
          "(As of: #{Time.current.strftime '%Y%m%d'})"
        ]
      },
      outstanding_fees: {
        headers: [
          'Name',
          'Email',
          'Fee Period',
          'Registration Fee',
          'Lake Cruise Fee',
          'Modifications',
          'Amount Paid',
          'Balance Owed'
        ]
      },
      cruisers: {
        headers: [
          'Cruisers',
          'Registrant',
          'E-mail',
          "(As of: #{Time.current.strftime '%Y%m%d'})"
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

    def select_layout
      action_name == 'print' ? "print_layout" : "admin_layout"
    end

    def calculate_annual_question
      # @annual_question_data = {
      #   number: Event::Registration.current.group(:annual_answer).reverse.count,
      #   options: AnnualQuestion::RESPONSES.reverse
      # }
    end

    def dedupe
      notice = []
      {
        KeyedContent => :key,
        ScheduledEvent => :name,
        Vendor => :name,
        Venue => :name }.each do |klass, attrib|
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
              total = total + r.paid_amount if r.complete?
            end
          end
          reg_data[year.to_s] << { daysOut: d, total: total }
        end
        @reg_data = reg_data.to_json
        @event_dates = event_dates.to_json
        @xLabels = (90).step(by: -1, to: 0).to_a.to_json
      end
    end

    def update_user_vehicles
      @user = User.find(params[:id])
      @registration = Event::Registration.where(year: Date.current.year).where(user: @user).first
      @vehicles = @user.vehicles
    end

    def manage
      render :manage
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

      @lake_cruise_reg = Event::Registration.where("lake_cruise_number > 0")
      @lake_cruise_count = @lake_cruise_reg.sum(:lake_cruise_number)
      @lake_cruise_fees_assessed = @lake_cruise_reg.sum(:lake_cruise_fee)
      @lake_cruise_fees_received = @lake_cruise_reg.where("balance > 0").sum(:lake_cruise_fee)

      @sunday_lunch_reg = Event::Registration.where("sunday_lunch_number > 0")
      @sunday_lunch_count = @sunday_lunch_reg.sum(:sunday_lunch_number)

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
      @year ||= Time.current.year

      base = Event::Registration.where(year: @year)
                                .where.not(status: 'cancelled')

      @registrations = Event::Registration
        .joins(:user)
        .where(year: @year)
        .where.not(status: 'cancelled')
        .order(:'users.last_name', :'users.first_name')

      if @registrations.blank?
        @registrations = []
        @users = []
        return
      end

      # -------------------------
      # Users (unchanged)
      # -------------------------
      # @users = case params[:user_type]
      #          when 'all_users' then User.all
      #          when 'active' then User.where('last_active > ?', 10.minutes.ago)
      #          when 'registrant' then User.with_registrations
      #          when 'testers' then User.with_role(:tester)
      #          when 'vendors' then User.with_role(:vendor)
      #          else User.with_current_registration
      #          end
      @users = User.ordered_by_current_year_registration

      @type = params[:user_type]&.humanize || 'Currently registered'

      # -------------------------
      # Registrations count
      # -------------------------
      @registration_count = base.count

      # -------------------------
      # Volunteers (simple + fast)
      # -------------------------
      @volunteers = Attendee
                    .joins(registration: :user)
                    .where(registrations: { year: @year }, volunteer: true)
                    .select('attendees.*, users.email as user_email')

      @volunteer_count = @volunteers.size

      # -------------------------
      # BIG STATS QUERY
      # -------------------------
      stats = base
        .left_joins(:attendees, :vehicles)
        .select(
          # Attendees
          "COUNT(DISTINCT attendees.id) AS attendee_count",
          "COUNT(DISTINCT CASE WHEN attendees.attendee_age = 'adult' THEN attendees.id END) AS adult_count",
          "COUNT(DISTINCT CASE WHEN attendees.attendee_age = 'youth' THEN attendees.id END) AS youth_count",
          "COUNT(DISTINCT CASE WHEN attendees.attendee_age = 'child' THEN attendees.id END) AS child_count",

          # Vehicles
          "COUNT(DISTINCT vehicles.id) AS vehicle_count",
          "COUNT(DISTINCT CASE WHEN vehicles.marque = 'Citroen' THEN vehicles.id END) AS citroen_count",
          "COUNT(DISTINCT CASE WHEN vehicles.marque != 'Citroen' THEN vehicles.id END) AS non_citroen_count",

          # Financials
          "SUM(DISTINCT registrations.registration_fee) AS registration_fee_sum",
          "SUM(DISTINCT registrations.donation) AS donation_sum",
          "SUM(DISTINCT registrations.lake_cruise_fee) AS lake_cruise_sum", # 👈 adjust column name if needed
          "SUM(DISTINCT registrations.total) AS total_sum",
          "SUM(DISTINCT registrations.paid_amount) AS paid_sum"
        )
        .take

      # -------------------------
      # Assign clean instance vars
      # -------------------------

      # Attendees
      @attendee_count = stats.attendee_count.to_i
      @adult_count    = stats.adult_count.to_i
      @youth_count    = stats.youth_count.to_i
      @child_count    = stats.child_count.to_i

      # Vehicles
      @vehicle_count     = stats.vehicle_count.to_i
      @citroen_count     = stats.citroen_count.to_i
      @non_citroen_count = stats.non_citroen_count.to_i

      # Financials
      financials = base.select(
        "SUM(registration_fee) AS registration_fee_sum",
        "SUM(donation) AS donation_sum",
        "SUM(lake_cruise_fee) AS lake_cruise_sum",
        "SUM(total) AS total_sum",
        "SUM(paid_amount) AS paid_sum"
      ).take

      @registration_fee_total = financials.registration_fee_sum.to_d
      @donation_total         = financials.donation_sum.to_d
      @lake_cruise_total      = financials.lake_cruise_sum.to_d
      @total_amount           = financials.total_sum.to_d
      @amount_paid            = financials.paid_sum.to_d
      @amount_due             = @total_amount - @amount_paid
    end

    def vehicle_dashboard
      vehicles = Vehicle.all
      @categorized_vehicles = categorize_vehicles(vehicles)
      @assigned_qr_codes = QrCode.assigned.count
      @blank_qr_codes = QrCode.unassigned.count
      @vehicles_without_codes = Vehicle.without_code.count
      @ballot_count = Voting::Ballot.where(year: Date.current.year).count
    end

    def peoples_choice_results
      @results = Voting::Ballot.top_vehicles_by_category # Defaults to current year and top 3
    end

    def clear_ballots
      Voting::Ballot.destroy_all
      flash_notice 'All ballots have been deleted'
      redirect_to :admin_dashboard
    end

    def print
      item = params[:item]
      case item
      when 'blank_placards'
        @qr_codes = QrCode.unassigned.limit(30)
        render "admin/admin/printing/blank_placards"
        return

      when 'placards'
        @vehicles = Vehicle.joins(user: :registrations)
                           .where(registrations: { year: Date.current.year })
                           .select('vehicles.*, users.last_name, users.first_name')
                           .order('users.last_name ASC, users.first_name ASC')
        render "admin/admin/printing/placards"
        return

      when 'labels'
        @registrations = Event::Registration.current
                                            .joins(:user)
                                            .order('users.last_name ASC', 'users.first_name ASC')
        render "admin/admin/printing/labels"
        return

      when 'invoices'
        @registrations = Event::Registration.current
                                            .joins(:user)
                                            .where('registrations.balance > 0.0')
                                            .order('users.last_name ASC', 'users.first_name ASC')
        render "admin/admin/printing/invoices"
        return


      when 'qr_code_stickers'
        @qr_codes = QrCode.limit(60)
        render "admin/admin/printing/:voting_code_stickers"
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

    def categorize_vehicles(vehicles)
      categorized_vehicles = Vehicles::VehicleTaxonomy.get_all_categories.map { |k| [k, []] }.to_h
      return categorized_vehicles unless vehicles.present?

      vehicles.each do |vehicle|
        categorized_vehicles[vehicle.judging_category] << vehicle
      end
      categorized_vehicles.sort_by { |category, _vehicles| category }.to_h
    end

    def get_csv_data(type)
      registrations = Event::Registration
                      .current
                      .includes(:attendees, :vehicles, :user)

      CSV.generate(headers: true) do |csv_data|
        csv_data << CSV_TYPES[type.to_sym][:headers]

        case type
        when 'registrants'
          registrations.find_each do |r|
            attendee_names = r.attendees.map(&:name).reject(&:blank?)
            registrant_name =
              if r.user.present?
                r.user.last_name_first
              else
                attendee_names.first.to_s
              end
            registrant_email =
              if r.user.present?
                r.user.email
              else
                '(none)'
              end

            guests = attendee_names.reject { |name| name == registrant_name }.join(', ')

            csv_data << [
              registrant_name,
              registrant_email,
              guests,
              r.lake_cruise_number,
              r.sunday_lunch_number
            ]
          end

      when 'outstanding_fees'
        registrations.find_each do |r|
          next unless r.balance > 0.0

          user = r.user

          registrant_name = user.last_name_first

          registrant_email =
            if user.email.present?
              r.user.email
            else
              '(none)'
            end
            csv_data << [
              registrant_name,
              registrant_email,
              r.fee_period,
              r.registration_fee,
              r.lake_cruise_fee,
              r.modifications.count.positive? ? 'Has modification(s)' : '',
              r.paid_amount,
              r.balance
            ]
        end

        when 'cruisers'
          registrations.find_each do |r|
            next unless r.lake_cruise_number.positive?

            attendee_names = r.attendees.map(&:name).reject(&:blank?)
            registrant_name =
              if r.user.present?
                r.user.last_name_first
              else
                attendee_names.first.to_s
              end
            registrant_email =
              if r.user.present?
                r.user.email
              else
                '(none)'
              end

            guests = attendee_names.reject { |name| name == registrant_name }.join(', ')

            csv_data << [
              guests,
              registrant_name,
              registrant_email
            ]
          end

        when 'dash_placards'
          registrations.each do |r|
            r.vehicles.each_with_index do |v, index|
              csv_data << [
                "#{r.invoice_number}-#{index + 1}",
                r.user&.last_name,
                r.user&.first_name,
                r.user&.full_name,
                v.year,
                v.marque,
                v.model,
                v.judging_category,
                v.other_info
              ]
            end
          end

        when 'packet_labels'
          registrations.each do |r|
            csv_data << [
              r.user&.last_name,
              r.attendees.map(&:name).join(', '),
              r.attendees.size,
              r.outstanding_balance? ? r.registration_fee : 'paid',
              r.donation.to_d.positive? ? r.donation : '',
              r.attendees.count(&:volunteer?)
            ]
          end

        when 'volunteers'
          registrations.each do |r|
            r.attendees.select(&:volunteer?).each do |a|
              csv_data << [
                a.name,
                r.user&.email
              ]
            end
          end
        end
      end
    end
  end
end
