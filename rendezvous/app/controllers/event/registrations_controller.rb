module Event
  class RegistrationsController < ApplicationController
    layout "registrations_layout"

    before_action :check_cutoff, only: [:new, :create, :complete, :edit]
    before_action :require_admin, only: [:index]
    before_action :authenticate_user!, except: [:welcome, :update_paid_method]
    before_action :owner_or_admin, only: [:show]
    before_action :set_cache_buster

    skip_before_action :verify_authenticity_token, only: [:show]

    def check_cutoff
      unless helpers.show_register
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

      @title = 'Registration - Start'
      @step = 'create'
      @annual_question = AnnualQuestion.where(year: Time.now.year).first

      if user_signed_in? && !session[:admin_user]
        @event_registration = current_user.registrations.current.first
        if !@event_registration.blank?
          flash_notice("You've already created a registration.")
          redirect_to edit_user_path(current_user)
          return
        end
      end

      @event_registration = Registration.new
      @event_registration.attendees.build

      if user_signed_in? && !session[:admin_user]
        @event_registration.user = current_user
      else
        @event_registration.build_user
      end
      @event_registration.user.vehicles.build
    end

    # Create or update the user
    def create
      unless verify_recaptcha?(params[:recaptcha_token], 'register_event')
        Rails.logger.warn "Event registration: recaptcha failed for email #{params[:event_registration][:user_attributes][:email]}"
        redirect_to root_path, notice: 'You have failed reCAPTCHA verification for event registration'
        return
      end

      if user_signed_in? && !session[:admin_user]
        user = User.find(current_user.id)
        if !user.update(event_registration_user_params)
          flash_alert 'There was a problem saving the user.'
          flash_alert user.errors.full_messages.to_sentence
          redirect_to event_welcome_path and return
        end
      else
        user = User.find_by_email(params[:event_registration][:user_attributes][:email])
        if user.blank?
          password = (65 + rand(26)).chr + 6.times.inject(''){|a, b| a + (97 + rand(26)).chr} + (48 + rand(10)).chr
          params[:event_registration][:user_attributes][:password] = password
          params[:event_registration][:user_attributes][:password_confirmation] = password
          user = User.new(event_registration_user_params)
          if !user.save
            flash_alert_now 'There was a problem saving your user information.'
            flash_alert_now user.errors.full_messages.to_sentence
            @event_registration = Registration.new
            @event_registration.attendees.build
            render 'registration_form' and return
          end
        end
      end

      # Done updating the user so remove those parameters
      params[:event_registration][:user_id] = user.id
      params[:event_registration][:user_attributes] = nil


      # Set total to registration fee. Donation happens in payment
      params[:event_registration][:total] = params[:event_registration][:registration_fee]

      @event_registration = Registration.new(event_registration_params)
      @event_registration.invoice_number = Registration.invoice_number

      if !@event_registration.save
        flash_alert_now('There was a problem creating your registration.')
        flash_alert_now @event_registration.errors.full_messages.to_sentence
        render 'registration_form' and return
      else
        sign_in(@event_registration.user) unless (session[:user_admin] || user_signed_in?)
        redirect_to review_event_registration_path(@event_registration)
      end
    end

    def edit
      @title = 'Edit Registration'
      @step = 'edit'

      @event_registration = Registration.find(params[:id])
    end

    def update

      @event_registration = Registration.find(params[:id])
      user = @event_registration.user

      user.update(event_registration_user_params)

      params[:event_registration][:user_id] = user.id
      params[:event_registration][:user_attributes] = nil

      # Set total to registration fee. Donation happens in payment
      params[:event_registration][:total] = params[:event_registration][:registration_fee]

      if @event_registration.update(event_registration_params)
        flash_notice 'The registration was updated.'
        redirect_to review_event_registration_path(@event_registration)
      else
        flash_alert 'There was a problem updating the registration.'
        flash_alert @event_registration.errors.full_messages.to_sentence
        redirect_to edit_event_registration_path(@event_registration)
      end
    end

    # AJAX method
    def update_paid_method
      @event_registration = Registration.find(params[:id])
      respond_to do |format|
        if @event_registration.update(payment_method_params)
          format.json {render json: { status: "ok", method: @event_registration.paid_method} }
        else
          format.json {render json: { status: "err", method: @event_registration.paid_method} }
        end
      end
    end

    def review
      @title = 'Review Registration Information'
      @step = 'review'
      @event_registration = Registration.find(params[:id])
      @event_registration.status = 'in review'
      @event_registration.save!
    end

    def payment
      @title = 'Registration - Payment'
      @step = 'payment'
      @event_registration = Registration.find(params[:id])
      @event_registration.total = @event_registration.registration_fee + @event_registration.donation
      @event_registration.status = 'payment due'
      @app_data[:event_registration_fee] = @event_registration.registration_fee
    end

    def send_to_square
      event_registration = Registration.find(params[:id])
      user = event_registration.user
      customer_id = ::RendezvousSquare::Customer.find_customer(user.email)

      if !customer_id
        customer_id = ::RendezvousSquare::Customer.create_customer(user)
      else
        Rails.logger.info("Square customer found: " + customer_id)
      end

      redirect_url = complete_after_online_payment_event_registration_url(event_registration)
      Rails.logger.info "***** Redirect URL: " + redirect_url
      square_payment_link = ::RendezvousSquare::Checkout.create_square_payment_link(event_registration, customer_id, redirect_url)
      redirect_to square_payment_link, allow_other_host: true
    end

    def complete_after_online_payment
      @title = 'Complete Registration'
      @step = 'complete'
      @event_registration = Registration.find(params[:id])
      @event_registration.paid_amount = @event_registration.total
      @event_registration.paid_method = 'credit card'
      @event_registration.cc_transaction_id
      @event_registration.paid_date = Time.new
      @event_registration.status = 'complete'
      if @event_registration.save
        send_confirmation_email
        flash_notice 'You are now registered for the Rendezvous! You should receive a confirmation by email shortly.'
        redirect_to update_vehicles_event_registration_path(@event_registration)
        return 
      else 
        flash_alert 'There was a problem completing your registration.'
        flash_alert @event_registration.errors.full_messages.to_sentence
        redirect_to payment_event_registration_path(@event_registration)
      end
    end        

    def complete
      @title = 'Complete Registration'
      @step = 'complete'
      @event_registration = Registration.find(params[:id])

      # Set the paid amounts
      @event_registration.paid_amount = 0.0
      @event_registration.paid_method = "cash or check"

      # Update the registration
      if !@event_registration.save
        flash_alert 'There was a problem completing your registration.'
        flash_alert @event_registration.errors.full_messages.to_sentence
        redirect_to payment_event_registration_path(@event_registration)
      else
        send_confirmation_email
        flash_notice 'You are now registered for the Rendezvous! You should receive a confirmation by email shortly.'
        redirect_to update_vehicles_event_registration_path(@event_registration)
      end
    end

    def update_vehicles
      @title = 'Vehicle Information'
      @step = 'vehicles'
      @event_registration = Registration.find(params[:id])
      @user = @event_registration.user
      @vehicles = @user.vehicles
    end

    def save_updated_vehicles
      @event_registration = Registration.find(params[:id])
      Rails.logger.debug params.inspect
      Rails.logger.info(format_for_logging(vehicle_update_params))
      if (@event_registration.update(vehicle_update_params))
        flash_notice "You are bringing #{@event_registration.vehicles.count} vehicles"
      else
        flash_alert "There was a problem saving your vehicle for this event."
      end
      redirect_to event_registration_path(@event_registration)
    end  

    def index
      @title = 'All Registrations'
      @event_registrations = Registration.all
    end

    def show
      @event_registration = Registration.find(params[:id])
    end

    def destroy
      @event_registration = Registration.find(params[:id])
      @event_registration.destroy
      flash_notice('Your registration has been deleted.')
      redirect_to user_path(current_user)
    end

    def welcome
      @step = 'welcome'
    end

    def send_confirmation_email
      event_registration = @event_registration || Registration.find(params[:id])
      if event_registration
        RendezvousMailer.registration_confirmation(event_registration).deliver_later
      else
        flash_notice('No registration found')
      end
      unless @event_registration
        if current_user.admin?
          redirect_to admin_dashboard_path
        else
          redirect_to :root
        end
      end
    end

    private
      # Only allows admins and owners to see registration
      def owner_or_admin
        unless (current_user.id == Registration.find(params[:id]).user_id) || (current_user.has_role? :admin)
          flash_alert 'Sorry, you must be an admin to see that.'
          redirect_to :root
        end
      end

      def event_registration_params
        params.require(:event_registration).permit(
          :number_of_adults,
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
          :invoice_number,
          :user_id,
          { attendees_attributes:
            [:id, :name, :attendee_age, :volunteer, :sunday_dinner, :_destroy]
          },
          {:user_attributes=>
            [:id, :email, :password, :password_confirmation, :first_name, :last_name, :address1, :address2, :city, :state_or_province, :postal_code, :country, :citroenvie,
              {vehicles_attributes:
                [:id, :year, :marque, :other_marque, :model, :other_model, :other_info, :for_sale, :_destroy]
              }
            ]
          }
        )
      end

      def payment_method_params
        params.permit(:id, :paid_method) 
      end

      def vehicle_update_params
        params.fetch(:event_registration, {}).permit(vehicle_ids: []).tap do |whitelisted|
          whitelisted[:vehicle_ids] ||= []  # Ensure it's an array even if nothing is checked
        end
      end

      def event_registration_user_params
        params[:user] = params[:event_registration][:user_attributes]
        params.require(:user).permit(
          [:id, :email, :password, :password_confirmation, :first_name, :last_name, :address1, :address2, :city, :state_or_province, :postal_code, :country, :citroenvie,
            {vehicles_attributes:
              [:id, :year, :marque, :other_marque, :model, :other_model, :other_info, :_destroy]
            }
          ]
        )
      end
  end
end

