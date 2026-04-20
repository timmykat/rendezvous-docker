module Event
  class RegistrationsController < ApplicationController
    layout "registrations_layout"

    before_action :get_registration, except: %i[index welcome new create new_by_admin create_by_admin destroy]
    before_action :set_registration_user, except: %i[welcome destroy]
    before_action :check_cutoff, only: %i[new create complete edit]
    before_action :require_admin, only: %i[index new_by_admin modify_by_admin cancel modify save_modification]
    before_action :authenticate_user!, except: %i[welcome update_paid_method update_fees]
    before_action :owner_or_admin, only: [:show]
    before_action :set_cache_buster
    before_action :filter_params_by_status, only: %i[update update_special_events]
    before_action :check_complete_destination, only: %i[new special_events review]

    skip_before_action :verify_authenticity_token, only: :show
    skip_before_action :set_incoming_destination, only: :complete_after_online_payment

    helper_method :previous_step
    helper_method :next_step
    helper_method :no_fee_related_changes

    STEPS = {
      welcome: {
        path: 'event_welcome',
        prev: nil,
        next: :creating
      },
      create: {
        path: 'new',
        prev: nil,
        next: :special_events
      },
      special_events: {
        path: 'special events',
        prev: :update,
        next: :review
      },
      review: {
        path: 'review',
        prev: :special_events,
        next: :payment
      },
      payment: {
        path: 'payment',
        prev: :review,
        next: nil
      },
      complete: {
        path: 'complete_after_payment',
        prev: :review,
        next: :vehicles
      },
      vehicles: {
        path: 'edit_user_vehicles',
        prev: :review,
        next: 'nil'
      },
      update: {
        path: 'edit',
        prev: nil,
        next: ->(status) { status == :complete ? :review : :special_events }
      }
    }.freeze

    NO_CHANGE_STATUSES = [
      :complete,
      :cancelled
    ]

    def get_registration
      @registration = Registration.find(params[:id])
      unless @registration
        flash_alert 'Get Registration: Registration not found.'
        redirect_to admin_dashboard_path
      end
    end

    def set_registration_user
      if @registration
        @user = @registration.user
        return
      end

      if params[:user_id]
        @user = User.find_by(id: params[:user_id])
        return
      end

      if params[:event_registration]
        @user = User.find_by(id: params.dig(:event_registration, :user_id))
      end

      @user = current_user unless current_user.admin?

      unless @user
        Rails.logger.warn('No registration user could be determined')
      end
    end

    def check_complete_destination
      if @registration
        redirect_to event_registration_path(@registration) if @registration.complete?
      end
    end

    def previous_step(current_step)
      return nil if current_step.nil?

      STEPS.dig(current_step.to_sym, :prev)
    end

    def next_step(current_step)
      step_config = STEPS[current_step&.to_sym]
      return nil unless step_config

      next_val = step_config[:next]

      # If it's a Proc (the lambda above), call it with the status
      # Otherwise, just return the value
      next_val.respond_to?(:call) ? next_val.call(status) : next_val
    end

    def no_fee_related_changes
      NO_CHANGE_STATUSES.include?(@registration.status) && !current_user.admin?
    end

    def check_cutoff
      if current_time > Rails.configuration.registration[:registration_window][:close].to_time
        flash_alert("Online registration is now closed. You may register on arrival at the Rendezvous.")
        redirect_to :root
      end
    end

    def set_cache_buster
      response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
      response.headers["Pragma"] = "no-cache"
      response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
    end

    def new
      if current_user&.admin?
        flash_alert 'Admins may not register'
        redirect_to admin_dashboard_path
        return
      end
      @title = "Let's get you registered!"
      build_registration
      @step = :creating
    end

    # Create or update the user
    def create
      Rails.logger.debug params
      @step = :creating
      email = params[:event_registration][:user_attributes][:email]
      user_id = params[:event_registration][:user_attributes][:id] || params[:event_registration][:user_id]

      if @user.nil? and !user_id.nil?
        @user = User.find(user_id)
        unless @user.update(event_registration_user_params)
          flash_alert 'There was a problem saving the user.'
          flash_alert user.errors.full_messages.to_sentence
          redirect_to event_welcome_path and return
        end
      end

      # Done updating the user so remove those parameters
      params[:event_registration][:user_id] = @user.id
      params[:event_registration][:user_attributes] = nil

      # Set total to registration fee. Donation happens in payment
      params[:event_registration][:total] = params[:event_registration][:registration_fee]

      @registration = Registration.new(event_registration_params)
      Rails.logger.debug @registration
      if current_user.admin?
        @registration.created_by_admin = params[:event_registration][:created_by_admin]
      end
      @registration.status = :in_progress
      @registration.invoice_number = "CR-#{Date.current.year}-#{@registration.id}"

      if !@registration.save
        flash_alert_now('There was a problem creating your registration.')
        flash_alert_now @registration.errors.full_messages.to_sentence
        render :new and return
      else
        @step = :special_events
        sign_in(@registration.user) unless (session[:user_admin] || user_signed_in?)
        redirect_to special_events_event_registration_path(@registration)
      end
    end

    def edit
      if no_fee_related_changes
        flash_alert "No changes can be made to the registration now."
        redirect_to show_event_registration_path(@registration)
      end

      @title = 'Update Registration'
      @step = :update
    end

    def update

      # Set total to registration fee. Donation happens in payment
      params[:event_registration][:total] = params[:event_registration][:registration_fee]

      if @registration.update(event_registration_params)
        if no_fee_related_changes
          flash_alert 'Now that your registration is complete you may only change vehicles or Sunday lunch.'
        else
          flash_notice 'The registration was updated.'
        end
        if @registration.status != :complete
          redirect_to special_events_event_registration_path(@registration)
        else
          redirect_to review_event_registration_path(@registration)
        end
      else
        flash_alert 'There was a problem updating the registration.'
        flash_alert @registration.errors.full_messages.to_sentence
        render :edit and return
      end
    end

    # Admin methods
    def new_by_admin
      @title = "Registration by admin"
      build_registration
    end

    def create_by_admin
      email = params[:event_registration][:user_attributes][:email]
      if !@user.present?
        @user = User.find_by_email(email) || create_new_user
      end

      # Remove user attributes now that we have user
      params[:event_registration][:user_attributes] = nil
      @registration = Registration.new(event_registration_params)
      @registration.user = @user

      if !@registration.save
        flash_alert_now('There was a problem creating the registration.')
        flash_alert_now @registration.errors.full_messages.to_sentence
        render :new_by_admin and return
      else
        redirect_to event_registration_path(@registration)
      end
    end

    def modify_by_admin
      @title = "Admin Registration Update"
      @no_total_update = @registration.complete?
    end

    def update_by_admin
      unless @user == @registration.user
        flash_alert "There is a user mismatch: #{@user.full_name} vs #{@registration.user.full_name}"
        render :edit_by_admin and return
      end

      if @registration.complete?
        flash_message = 'This registration is complete. Do you want to create a modification?<br>'
      else
        flash_message = ''
      end

      if @registration.update(event_registration_params)
        flash_message += 'Registration updated'.html_safe
        flash_notice flash_message
        redirect_to event_registration_path(@registration) and return
      else
        flash_alert @registration.errors.full_messages.to_sentence
        render :edit_by_admin
      end
    end

    def modify
      existing = @registration.modifications.where(status: 'in progress').exists?
      if existing
        flash_alert 'An existing modification is in progress. Please resolve that first.'
        redirect_to event_registration_path(@registration) and return
      end

      @modification = create_modification
      unless @modification.save
        flash_alert 'The modification was not successfully created'
        render :modify_by_admin and return
      end
      redirect_to event_modification_path(@modification.id) and return
    end

    def create_modification(cancellation: false)
      db_reg = @registration.class.find(@registration.id)

      fee_period = db_reg.late_period? ? :late : :early
      env = RendezvousSquare::Apis::Base.env_key
      reg_fees = Rails.configuration.orders[env][fee_period]
      lake_cruise_fee = Rails.configuration.orders[env][:lake_cruise][:price]

      m = db_reg.modifications.build
      m.status = :pending

      reg_params = params[:event_registration]
      Event::Registration::AGE_GROUPS.each do |age|
        plural = age.pluralize
        number = "number_of_#{plural}"
        starting = "starting_#{plural}"
        delta = "delta_#{plural}"

        starting_value = db_reg.send(number) || 0
        m.send("#{starting}=", starting_value)

        new_val = (reg_params[number.to_sym] || 0).to_i
        m.send("#{delta}=", new_val - starting_value)
      end
      m.starting_lake_cruise = db_reg.lake_cruise_number || 0

      Event::Registration::AGE_GROUPS.each do |age|
        plural = age.pluralize
        number = "number_of_#{plural}".to_sym
        starting = "starting_#{plural}"
        delta = "delta_#{plural}"
        m.send("#{delta}=", (reg_params[number] || 0).to_i - m.send(starting))
      end
      m.delta_lake_cruise = (reg_params[:lake_cruise_number] || 0).to_i - m.starting_lake_cruise

      m.new_attendee_fee = Event::Registration::AGE_GROUPS.sum do |age|
        delta = m.send("delta_#{age.pluralize}")
        delta.zero? ? 0 : delta * reg_fees[age.to_sym]
      end

      m.new_lake_cruise_fee = m.delta_lake_cruise * lake_cruise_fee
      m.modification_total = m.new_attendee_fee.to_d + m.new_lake_cruise_fee.to_d
      m.new_total = @registration.total + m.modification_total
      m.cancellation = true if cancellation
      m
    end

    def cancel
    end

    def save_modification
    end

    # AJAX methods
    def update_fees
      @registration = Registration.find(params[:id])

      if @registration.update(update_fees_params)
        render json: {
          status: "ok",
          data: {
            donation: @registration.donation,
            total: @registration.total
          }
        }, status: :ok
      else
        render json: {
          status: "error",
          errors: @registration.errors.full_messages,
          data: {
            donation: @registration.donation_was, # Send back the old value
            total: @registration.total_was
          }
        }, status: :unprocessable_entity
      end
    end

    def update_paid_method
      @registration = Registration.find(params[:id])
      respond_to do |format|
        if @registration.update(payment_method_params)
          format.json { render json: { status: "ok", method: @registration.paid_method } }
        else
          format.json { render json: { status: "err", method: @registration.paid_method } }
        end
      end
    end

    def review
      @step = :review
      @title = 'Review Registration Information'
      @registration.save
    end

    def payment
      @step = :payment
      @title = 'Registration - Payment'
      @app_data.merge!({
                         event_registration_fee: @registration.registration_fee,
                         registration_id: @registration.id
                       })
    end

    def pay_by_admin
      begin
        send_order_to_square
        flash_notice 'The order was successfully created'
        redirect_to admin_dashboard_path
      rescue Square::Errors::ApiError => e
        flash_alert "There was a problem creating the order: #{e.message}"
        Rails.logger.error("Square order failed: #{e.message}")
        render :modify_by_admin
      end
    end

    def special_events
      @step = :special_events
      @title = 'Registration - Special Events'
    end

    def update_special_events
      go_back = params[:go_back]
      if no_fee_related_changes
        if go_back
          redirect_to edit_event_registration_path(@registration)
        else
          redirect_to review_event_registration_path(@registration)
        end
      else
        if @registration.update(special_events_params)
          flash_notice 'Special events were updated.'
          if go_back
            redirect_to edit_event_registration_path(@registration)
          else
            redirect_to review_event_registration_path(@registration)
          end
        else
          flash_alert "There was a problem saving your special events info."
          render :special_events
        end
      end
    end

    def complete_after_online_payment
      @title = 'Complete Registration'
      @step = :finished

      transaction_id = params[:transactionId]
      order_id = params[:orderId]
      if transaction_id && order_id
        transaction = ::Square::Transaction.new
        transaction.user = @registration.user
        transaction.amount = @registration.total
        transaction.transaction_id = transaction_id
        transaction.order_id = order_id
        transaction.registration_id = @registration.id
        transaction.save
      end

      if @registration.update(
        paid_amount: @registration.total,
        balance: 0.0,
        paid_method: :credit_card,
        paid_date: Time.new,
        status: :complete
      )

        send_confirmation
        flash_notice 'You are now registered for the Rendezvous! You should receive a confirmation by email shortly.'
        if current_user.admin?
          redirect_to admin_dashboard_path and return
        else
          redirect_to edit_user_vehicles_path(@user, after_complete: true) and return
        end
      else
        flash_alert 'There was a problem completing your registration.'
        flash_alert @registration.errors.full_messages.to_sentence
        render :payment and return
      end
    end

    def complete
      @step = :finished
      @title = 'Complete Registration'

      unless @registration.update(
        status: :complete,
        paid_amount: 0.0,
        paid_method: :cash_or_check
      )
        flash_alert 'There was a problem completing your registration.'
        flash_alert @registration.errors.full_messages.to_sentence
        render :show
        return
      end

      # TBD - creation of Square order and invoice
      # begin
      #   order = create_square_order
      # rescue Square::Errors::ApiError => e
      #   flash_alert 'Your registration is saved, but there was a problem creating your Square order'
      # end

      # if order
      #   send_square_invoice(order)
      # end

      send_confirmation
      flash_notice 'You are now registered for the Rendezvous! You should receive a confirmation by email shortly.'
      redirect_to edit_user_vehicles_path(@user)
    end

    def save_updated_vehicles
      if (@registration.update(vehicle_update_params))
        flash_notice "You are bringing #{@registration.vehicles.count} vehicles"
      else
        flash_alert "There was a problem saving your vehicles"
      end
      redirect_to event_registration_path(@registration)
    end

    def edit_sunday_lunch
      @registration = Registration.find(params[:id])
    end

    def update_sunday_lunch
      if (@registration.update(sunday_lunch_params))
        flash_notice @registration.sunday_lunch_number == 0 ? "You're not attending Sunday lunch." : "You've updated your Sunday lunch guests to #{@registration.sunday_lunch_number}"
      else
        flash_alert "There was a problem saving your Sunday lunch info"
        render :edit_sunday_lunch and return
      end
      redirect_to landing_page_path
    end

    def index
      @title = 'All Registrations'
      @registrations = Registration.all
    end

    def show
      @registration = Registration.find(params[:id])
    end

    def destroy
      @registration = Registration.find(params[:id])
      @registration.destroy
      flash_notice('Your registration has been deleted.')
      redirect_to admin_dashboard_path
    rescue ActiveRecord::RecordNotFound => e
      redirect_to admin_dashboard_path, alert: "Event not found: #{e.full_message}"
    end

    def welcome
      @step = :welcome
    end

    # def create_square_order
    #   begin
    #     order = ::RendezvousSquare::Apis::Order.create({
    #       registration: @registration,
    #       customer_id: customer_id,
    #       redirect_url: redirect_url,
    #       fee_period: fee_period,
    #       order_type: "Event Registration"
    #     })
    #   rescue Square::Errors::ApiError => e
    #     flash_alert "There was a problem creating the order: #{e.message}"
    #     return false
    #   end
    #   order
    # end

    # def send_square_invoice(order)
    #   params = {
    #     order_id: order[:id]
    #   }
    # end
    def payment_request
      user = @registration.user
      customer_id = user.ensure_square_customer_id!
      begin
        square_payment_link = ::RendezvousSquare::Apis::Base.with_error_handling do
          RendezvousSquare::Apis::Checkout.create_square_payment_link({
                                                                        registration: @registration,
                                                                        customer_id: customer_id,
                                                                        fee_period: fee_period
                                                                      })
        end
      rescue Square::Errors::ApiError => e
        flash_alert "There was a problem creating the link: #{e.message}"
        render :show
      end

      unless square_payment_link
        flash_alert "There was an unknown problem creating the payment link."
        render :show and return
      end

      RendezvousMailer.send_registration_payment_link(@registration.id, square_payment_link).deliver_later
      flash_notice 'The payment link has been queued to send'
      redirect_to admin_dashboard_path
    end

    def send_to_square
      @step = :payment
      @registration = Registration.find(params[:id])
      if !@registration.update(update_payment_params)
        flash_alert "There was a problem making your payment update; no payment submitted"
        render :payment
      end

      @registration.update(status: :complete)

      user = @registration.user

      customer_id = user.ensure_square_customer_id!

      redirect_url = complete_after_online_payment_event_registration_url(@registration)
      begin
        square_payment_link = ::RendezvousSquare::Apis::Base.with_error_handling do
          RendezvousSquare::Apis::Checkout.create_square_payment_link({
                                                                        registration: @registration,
                                                                        customer_id: customer_id,
                                                                        redirect_url: redirect_url,
                                                                        fee_period: fee_period
                                                                      })
        end
      rescue Square::Errors::ApiError => e
        flash_alert "There was a problem creating the link: #{e.message}"
        render :payment
      end

      if square_payment_link.nil?
        flash_alert 'Square was unable to generate a payment link.'
        render :payment
      else
        redirect_to square_payment_link, allow_other_host: true
      end
    end

    def send_confirmation
      registration = @registration || Event::Registration.find(params[:id])
      unless registration
        flash_alert('No registration found')
        if current_user.admin?
          redirect_to admin_dashboard_path
        else
          return redirect_to :root
        end
        return
      end

      RendezvousMailer.registration_confirmation(registration.id).deliver_later
      return unless params[:self_send]

      redirect_to event_registration_path(@registration)
    end

    private

    def build_registration
      @step = :create
      @annual_question = AnnualQuestion.where(year: Date.current.year).first

      @registration = @user&.registrations&.current&.first

      if @registration.blank?
        @registration = Registration.new(status: :in_progress, created_by_admin: current_user.admin?)
      else
        unless current_user.admin?
          if @registration.in_progress?
            flash_notice('You have a registration in progress')
            redirect_to review_event_registration_path(@registration) and return
          end

          if @registration.complete?
            flash_notice("You've already registered")
            redirect_to event_registration_path(@registration) and return
          end
        end
      end

      if @user.present?
        @registration.user = @user
        registrant_attendee = Attendee.new
        registrant_attendee.name = @user.full_name
        @registration.attendees << registrant_attendee
        @registration.user.vehicles.build
      end
    end

    def filter_params_by_status
      @registration = Registration.find(params[:id])

      # Check if the registration is "locked"
      if no_fee_related_changes
        # Strip out cost-affecting params if they exist in the request
        params[:event_registration].delete(:number_of_adults)
        params[:event_registration].delete(:number_of_youths)
        params[:event_registration].delete(:number_of_children)
        params[:event_registration].delete(:lake_cruise_number)
        params[:event_registration].delete(:attendees_attributes)
        params[:event_registration].delete(:total)
        params[:event_registration].delete(:paid_amount)
        params[:event_registration].delete(:paid_method)
        params[:event_registration].delete(:paid_date)
        params[:event_registration].delete(:payment_token)
        params[:event_registration].delete(:status)

        # Optional: Log a warning or set a flash message
        Rails.logger.warn "Locked registration update attempt: ID #{@registration.id}"
      end
    end

    def create_new_user
      password = (65 + rand(26)).chr + 6.times.inject('') { |a, b| a + (97 + rand(26)).chr } + (48 + rand(10)).chr
      params[:event_registration][:user_attributes][:password] = password
      params[:event_registration][:user_attributes][:password_confirmation] = password
      user = User.new(event_registration_user_params)
      if !user.save
        flash_alert_now 'There was a problem saving that user information.'
        flash_alert_now user.errors.full_messages.to_sentence
        render :by_admin
        return
      else
        return user
      end
    end

    # Only allows admins and owners to see registration
    def owner_or_admin
      unless (current_user.id == Registration.find(params[:id]).user_id) || require_admin
        flash_alert 'Sorry, you must be an admin to see that.'
        redirect_to :root
      end
    end

    def update_payment_params
      params.permit(
        :id,
        :registration_fee,
        :donation,
        :total,
        :paid_amount,
        :paid_method,
        :paid_date
      )
    end

    def event_registration_params
      params.require(:event_registration).permit(
        :annual_answer,
        :number_of_adults,
        :number_of_youths,
        :number_of_children,
        :registration_fee,
        :donation,
        :total,
        :year,
        :paid_amount,
        :paid_method,
        :paid_date,
        :payment_token,
        :status,
        :lake_cruise_number,
        :lake_cruise_fee,
        :sunday_lunch_number,
        :invoice_number,
        :user_id,
        { attendees_attributes:
            [:id, :name, :attendee_age, :volunteer, :_destroy]
        },
        { :user_attributes =>
            [:id, :email, :password, :password_confirmation, :first_name, :last_name, :address1, :address2, :city, :state_or_province, :postal_code, :country, :citroenvie,
             { vehicles_attributes:
                 [:id, :year, :marque, :other_marque, :model, :other_model, :other_info, :for_sale, :_destroy]
             }
            ]
        }
      )
    end

    def update_fees_params
      params.permit(:id, :donation)
    end

    def cash_payment_params
      params.require(:event_registration).permit(:donation, :total, :paid_method, :paid_amount, :status)
    end

    def payment_method_params
      params.permit(:id, :paid_method)
    end

    def sunday_lunch_params
      params.require(:event_registration).permit(:sunday_lunch_number)
    end

    def vehicle_update_params
      params.fetch(:event_registration, {}).permit(vehicle_ids: []).tap do |whitelisted|
        whitelisted[:vehicle_ids] ||= [] # Ensure it's an array even if nothing is checked
      end
    end

    def special_events_params
      params.require(:event_registration).permit(
        :lake_cruise_number,
        :lake_cruise_fee,
        :sunday_lunch_number
      )
    end

    def event_registration_user_params
      params
        .require(:event_registration)
        .require(:user_attributes)
        .permit(
          :id, :email, :password, :password_confirmation,
          :first_name, :last_name,
          :address1, :address2, :city, :state_or_province,
          :postal_code, :country, :citroenvie,
          vehicles_attributes: [
            :id, :year, :marque, :other_marque,
            :model, :other_model, :other_info, :_destroy
          ]
        )
    end
  end
end
