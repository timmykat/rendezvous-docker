require 'csv'
require 'fileutils'

module Admin
  class AdminController < ApplicationController

    layout :select_layout

    NO_USER_ID = 999999

    CSV_TYPES = {
      attendees: {
        headers: [
          'Registration number',
          'Registrant',
          'Attendee name',
          'Adult, youth, or child',
          'Volunteer?',
          'Donation?',
          'Date registration paid',
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

      @registrations = base = Event::Registration.where(year: @year)

      # -------------------------
      # Users (unchanged)
      # -------------------------
      @users = case params[:user_type]
               when 'all_users' then User.all
               when 'active' then User.where('last_active > ?', 10.minutes.ago)
               when 'registrant' then User.with_registrations
               when 'testers' then User.with_role(:tester)
               when 'vendors' then User.with_role(:vendor)
               else User.with_current_registration
               end

      @type = params[:user_type]&.humanize || 'Currently registered'

      # -------------------------
      # Registrations count
      # -------------------------
      @registration_count = base.count

      # -------------------------
      # Volunteers (simple + fast)
      # -------------------------
      @volunteer_count = Attendee
        .joins(:registration)
        .where(registrations: { year: @year }, volunteer: true)
        .count

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
        Rails.logger.debug "Removing old QR codes"
        FileUtils.rm_rf(Dir.glob(Rails.root.join('public', 'qr_codes', '*')))
      end
      Rails.logger.debug "Kicking off job"
      QrGenerationJob.perform_later(regenerate)
      flash_notice 'QR generation job started'
      @vehicles = nil
      redirect_to admin_manage_qr_codes_path
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
        render :blank_placards
        return
      when 'placards'
        @vehicles = Vehicle.joins(user: :registrations)
                           .where(registrations: { year: 2025 })
                           .distinct
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
        Event::Registration.current.each do |r|
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
                (!r.donation.blank? && (r.donation.to_d > 0.0)) ? 'Yes' : 'No',
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
              r.attendees.map { |a| a.name }.join('<br>'),
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
end
