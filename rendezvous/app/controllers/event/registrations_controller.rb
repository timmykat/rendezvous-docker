module Event
  class RegistrationsController < ApplicationController
    layout "registrations_layout"

    before_action :check_cutoff, only: [:new, :create, :complete, :edit]
    before_action :require_admin, only: [:index, :register_by_admin]
    before_action :authenticate_user!, except: [:welcome, :update_paid_method, :update_fees]
    before_action :owner_or_admin, only: [:show]
    before_action :set_cache_buster

    skip_before_action :verify_authenticity_token, only: [:show]

    def check_cutoff
      if !current_user&.admin? && Time.now > Config::SiteSetting.instance.registration_close_date
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
      if current_user && current_user.admin?
        @title = "Create new registration"
      else 
        @title = "Let's get you registered!"
      end

      @step = 'create'
      @annual_question = AnnualQuestion.where(year: Date.current.year).first

      if current_user && !current_user.admin?
        @event_registration = current_user.registrations.current.first
        if !@event_registration.blank?
          if !['payment due', 'complete'].include?(@event_registration.status)
            flash_notice("You've already created a registration but haven't finished")
            redirect_to review_event_registration_path(@event_registration)
          else
            flash_notice("You've already registered")
            redirect_to event_registration_path(@event_registration)
          end
          return
        end
      end

      if current_user.admin? 
        @event_registration = Registration.new(created_by_admin: true)
      else
        @event_registration = Registration.new
      end

      @event_registration.attendees.build

      if current_user && !current_user.admin?
        @event_registration.user = current_user
      else
        @event_registration.build_user
      end
      @event_registration.user.vehicles.build
    end

    def by_admin
      session[:admin_created] = true
      @title = "Registration by admin"
      @step = 'create'
      @annual_question = AnnualQuestion.find_by(year: Date.current.year)
    
      user = User.find_by(id: params[:user_id])
      @event_registration = Registration.new(created_by_admin: true)
      @event_registration.attendees.build
    
      if user
        @event_registration.user = user
      else
        @event_registration.build_user
      end
    
      @event_registration.user.vehicles.build
    end

    # Create or update the user
    def create
      email = params[:event_registration][:user_attributes][:email]
      user_id = params[:event_registration][:user_attributes][:id] || params[:event_registration][:user_id]

      failure_message = verify_recaptcha?(params[:recaptcha_token], 'register_event', email)
      if failure_message
        Rails.logger.warn "Event registration: recaptcha failed for #{email}"
        redirect_to root_path, notice: failure_message
        return
      end

      if !user_id.nil?
        user = User.find(user_id)
        if !user.update(event_registration_user_params)
          flash_alert 'There was a problem saving the user.'
          flash_alert user.errors.full_messages.to_sentence
          redirect_to event_welcome_path and return
        end
      else
        user = User.find_by_email(email)
        if user.blank?
          password = (65 + rand(26)).chr + 6.times.inject(''){|a, b| a + (97 + rand(26)).chr} + (48 + rand(10)).chr
          params[:event_registration][:user_attributes][:password] = password
          params[:event_registration][:user_attributes][:password_confirmation] = password
          user = User.new(event_registration_user_params)
          if !user.save
            flash_alert_now 'There was a problem saving your user information.'
            flash_alert_now user.errors.full_messages.to_sentence
            render :new
            return
          end
        end
      end

      # Done updating the user so remove those parameters
      params[:event_registration][:user_id] = user.id
      params[:event_registration][:user_attributes] = nil


      # Set total to registration fee. Donation happens in payment
      params[:event_registration][:total] = params[:event_registration][:registration_fee]

      @event_registration = Registration.new(event_registration_params)
      if current_user.admin?
        @event_registration.created_by_admin = params[:event_registration][:created_by_admin]
      end
      @event_registration.invoice_number = Registration.invoice_number

      if !@event_registration.save
        flash_alert_now('There was a problem creating your registration.')
        flash_alert_now @event_registration.errors.full_messages.to_sentence
        render :new and return
      else
        sign_in(@event_registration.user) unless (session[:user_admin] || user_signed_in?)
        redirect_to review_event_registration_path(@event_registration)
      end
    end

    def create_by_admin
      user_id = params[:event_registration][:user_attributes][:id]
      email = params[:event_registration][:user_attributes][:email]
      if !user_id.nil?
        user = User.find(user_id)
      end
      if !user.present?
        user = User.find_by_email(email)
      end
      if !user.present?
        user = create_new_user
      end

      failure_message = verify_recaptcha?(params[:recaptcha_token], 'register_event', email)
      if failure_message
        Rails.logger.warn "Event registration: recaptcha failed for #{email}"
        redirect_to root_path, notice: failure_message
        return
      end

      # Remove user attributes now that we have user
      params[:event_registration][:user_attributes] = nil
      @event_registration = Registration.new(event_registration_params)
      @event_registration.user = user

      if !@event_registration.save
        flash_alert_now('There was a problem creating the registration.')
        flash_alert_now @event_registration.errors.full_messages.to_sentence
        render :by_admin and return
      else
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

    # AJAX methods
    def update_fees
      @event_registration = Registration.find(params[:id])
      respond_to do |format|
        if !@event_registration.update(update_fees_params)
          format.json { render json: { status: "error", data: { 
              donation:  @event_registration.donation,
              total: @event_registration.total 
            }}}
        else
          format.json { render json: { status: "ok", data: { 
            donation:  @event_registration.donation,
            total: @event_registration.total 
          }}}
        end
      end
    end

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
      # If user is a vendor, add the registration fee
      if (@event_registration.user.has_role? :vendor)
        vendor_fee = Config::SiteSetting.instance.vendor_fee
        @event_registration.vendor_fee = vendor_fee
        # @event_registration.ensure_total
        @event_registration.save!
      end 
      @event_registration.status = 'in review'
      @event_registration.save!
    end

    def payment
      @title = 'Registration - Payment'
      @step = 'payment'
      @event_registration = Registration.find(params[:id])
      @event_registration.status = 'payment due'
      @app_data[:event_registration_fee] = @event_registration.registration_fee

      # Set up square env
      square_env = RendezvousSquare::Base.get_environment
      @square_app_id = ENV.fetch "#{square_env}_SQUARE_APP_ID"
      @square_sdk_url = ENV.fetch "#{square_env}_SQUARE_SDK_URL"
      @square_location_id = ENV.fetch "#{square_env}_SQUARE_LOCATION_ID"
    end

    def send_to_square
      @event_registration = Registration.find(params[:id]) 
      if !@event_registration.update(update_payment_params)
        flash_alert "There was a problem making your payment update; no payment submitted"
        render :payment
      end

      user = @event_registration.user
      customer_id = ::RendezvousSquare::Base.with_error_handling do
        ::RendezvousSquare::Customer.find_customer(user.email)
      end

      if customer_id.nil?
        customer_id = ::RendezvousSquare::Base.with_error_handling do
          ::RendezvousSquare::Customer.create_customer(user)
        end
      else
        Rails.logger.info("Square customer found: " + customer_id)
      end

      redirect_url = complete_after_online_payment_event_registration_url(@event_registration)

      square_payment_link = ::RendezvousSquare::Base.with_error_handling do
        RendezvousSquare::Checkout.create_square_payment_link(@event_registration, customer_id, redirect_url)
      end

      unless square_payment_link.nil?
        redirect_to square_payment_link, allow_other_host: true
      else 
        flash_alert "Square was unable to generate a payment link."
        redirect_to payment_event_registration_path(@event_registration)
      end
    end

    def complete_after_online_payment
      @title = 'Complete Registration'
      @step = 'complete'
      @event_registration = Registration.find(params[:id])

      transaction_id = params[:transactionId]
      order_id = params[:orderId]
      if transaction_id && order_id
        transaction = SquareTransaction.new
        transaction.user = @event_registration.user
        transaction.amount = @event_registration.total
        transaction.transaction_id = transaction_id
        transaction.order_id = order_id
        transaction.registration_id = @event_registration.id
        transaction.save
      end

      @event_registration.paid_amount = @event_registration.total
      @event_registration.paid_method = 'credit card'
      @event_registration.paid_date = Time.new
      @event_registration.status = 'complete'
      if @event_registration.save
        send_confirmation_email
        flash_notice 'You are now registered for the Rendezvous! You should receive a confirmation by email shortly.'
        if current_user.admin?
          redirect_to user_path(@event_registration.user)
        else
          redirect_to update_vehicles_event_registration_path(@event_registration)
        end
        return 
      else 
        flash_alert 'There was a problem completing your registration.'
        flash_alert @event_registration.errors.full_messages.to_sentence
        render payment_event_registration_path(@event_registration)
      end
    end        

    def complete
      @title = 'Complete Registration'
      @step = 'complete'
      @event_registration = Registration.find(params[:id])

      # Set the paid amounts
      if current_user.admin?
        if !@event_registration.update(cash_payment_params)
          flash_alert 'Something went wrong with the completion attempt'
          render :payment
        else
          if @event_registration.status == 'complete'
            @event_registration.paid_date = Time.new
            @event_registration.save
          end
          flash_notice 'The registration was successfully updated.'
          redirect_to user_path(@event_registration.user)
        end
        return
      end

      @event_registration.paid_amount = 0.0
      @event_registration.paid_method = "cash or check"

      # Update the registration
      if !@event_registration.save
        flash_alert 'There was a problem completing your registration.'
        flash_alert @event_registration.errors.full_messages.to_sentence
        render :show
      else
        send_confirmation_email
        flash_notice 'You are now registered for the Rendezvous! You should receive a confirmation by email shortly.'
        redirect_to update_vehicles_event_registration_path(@event_registration)
      end
    end

    def post_reg_update_vehicles
      @event_registration = Registration.find(params[:id])
      @user = @event_registration.user
      @vehicles = @user.vehicles
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
      def create_new_user
        password = (65 + rand(26)).chr + 6.times.inject(''){|a, b| a + (97 + rand(26)).chr} + (48 + rand(10)).chr
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
        unless (current_user.id == Registration.find(params[:id]).user_id) || (current_user.has_role? :admin)
          flash_alert 'Sorry, you must be an admin to see that.'
          redirect_to :root
        end
      end

      def update_payment_params
        params.permit(
          :id,
          :registration_fee,
          :vendor_fee,
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
          :number_of_children,
          :registration_fee,
          :vendor_fee,
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
            [:id, :name, :attendee_age, :volunteer, :_destroy]
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

      def update_fees_params
        params.permit(:id, :donation, :total)
      end

      def cash_payment_params
        params.require(:event_registration).permit(:donation, :total, :paid_method, :paid_amount, :status)
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

