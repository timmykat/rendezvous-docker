module Event
  class RegistrationsController < ApplicationController

    before_action :check_cutoff, only: [:new, :create, :complete, :edit]
    before_action :require_admin, only: [:index]
    before_action :authenticate_user!, except: [:welcome]
    before_action :owner_or_admin, only: [:show]
    before_action :set_cache_buster

    skip_before_action :verify_authenticity_token, only: [:show]

    def check_cutoff
      unless helpers.can_register?
        flash_alert("Online registration is now closed. You may register on arrival at the Rendezvous.")
        redirect_to :root
      end
    end

    def get_payment_token
      render plain:  ENV['BRAINTREE_TOKENIZATION_KEY'], content_type: 'text/plain'
    end

    def set_cache_buster
      response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
      response.headers["Pragma"] = "no-cache"
      response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
    end

    def new

      @title = 'Registration - Start'

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

    def create

      # Create or update the user
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
        handle_mailchimp(@event_registration.user)
        sign_in(@event_registration.user) unless (session[:user_admin] || user_signed_in?)
        redirect_to review_event_registration_path(@event_registration)
      end
    end

    def edit
      @title = 'Edit Registration'

      @event_registration = Registration.find(params[:id])
      render 'registration_form'
    end

    def update

      @event_registration = Registration.find(params[:id])
      user = @event_registration.user
      mailchimp_init = user.receive_mailings

      user.update(event_registration_user_params)

      handle_mailchimp(user) unless user.receive_mailings == mailchimp_init
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

    def review
      @title = 'Review Registration Information'
      @event_registration = Registration.find(params[:id])
      @event_registration.status = 'in review'
      @event_registration.save!
    end

    def payment
      @title = 'Registration - Payment'
      begin
        @title = 'Registration - Payment'
        @event_registration = Registration.find(params[:id])
        @event_registration.status = 'payment due'
        @app_data[:event_registration_fee] = @event_registration.registration_fee
        @credit_connection = true
      rescue Braintree::BraintreeError => e
        @credit_connection = false
        flash_alert("We're sorry but the connection to our credit card processor isn't available. Please pay later, or register now and choose pay by check.")
        flash_alert e.inspect
        # redirect_to payment_event_registration_path(@event_registration)
      end
    end


    def complete
      @title = 'Complete Registration'
      @event_registration = Registration.find(params[:id])
      @event_registration.update(event_registration_params)

      # If this is a credit card transaction, set the customer and billing attributes
      # (have to do it now, in case this is an existing user and the user attributes are removed laster

      if params[:event_registration][:paid_method] == 'credit card' && !params[:payment_method_nonce].blank?
        braintree_transaction_params = {
          order_id: @event_registration.invoice_number,
          amount: @event_registration.total,
          payment_method_nonce: params[:payment_method_nonce],
          customer: {
            first_name: @event_registration.user.first_name,
            last_name: @event_registration.user.last_name,
            email: @event_registration.user.email,
          },
          billing: {
            first_name: @event_registration.user.first_name,
            last_name: @event_registration.user.last_name,
            street_address: @event_registration.user.address1,
            extended_address: @event_registration.user.address2,
            locality: @event_registration.user.city,
            region: @event_registration.user.state_or_province,
            postal_code: @event_registration.user.postal_code,
            country_code_alpha3: @event_registration.user.country
          },
          options: {
            submit_for_settlement: true
          },
        }

        gateway = Braintree::Gateway.new(
          environment: Braintree::Configuration.environment,
          merchant_id: Braintree::Configuration.merchant_id,
          public_key: Braintree::Configuration.public_key,
          private_key: Braintree::Configuration.private_key,
        )

        result = gateway.transaction.sale(braintree_transaction_params)

        if result.success?

          logger.info "Braintree transaction success for #{@event_registration.user.email}"

          # Create a new transaction
          @event_registration.transactions << Transaction.new(
            transaction_method: 'credit card',
            transaction_type: 'payment',
            cc_transaction_id: result.transaction.id,
            amount: @event_registration.total
          )

          @event_registration.paid_amount = @event_registration.total
          @event_registration.paid_method = 'credit card'
          @event_registration.cc_transaction_id = result.transaction.id
          @event_registration.paid_date = Time.new
          @event_registration.status = 'complete'
          @event_registration.save!
          send_confirmation_emails
          flash_notice 'You are now registered for the Rendezvous! You should receive a confirmation by email shortly.'
          redirect_to vehicles_event_registration_path(@event_registration)
          return
        elsif result.errors
          logger.debug "Braintree transaction error for #{@event_registration.user.email}"
          logger.debug result.message
          flash_alert 'There was a problem with your credit card payment.'
          flash_alert result.message
          redirect_to payment_event_registration_path(@event_registration)
          return
        end
      end

      # Set the paid amounts
      params[:event_registration][:total] = params[:event_registration][:total].to_f
      if params[:event_registration][:paid_method] == 'credit card'
        params[:event_registration][:paid_amount] = params[:event_registration][:total]
      else
        params[:event_registration][:paid_amount] = 0.00
      end

      # Update the registration
      if !@event_registration.update(event_registration_params)
        flash_alert 'There was a problem completing your registration.'
        flash_alert @event_registration.errors.full_messages.to_sentence
        redirect_to payment_event_registration_path(@event_registration)
      else
        send_confirmation_emails
        flash_notice 'You are now registered for the Rendezvous! You should receive a confirmation by email shortly.'
        redirect_to vehicles_event_registration_path(@event_registration)
      end
    end

    def vehicles
      @title = 'Vehicle Information'

      @event_registration = Registration.find(params[:id])
      @user = @event_registration.user
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

    end

    def send_email
      event_registration = Registration.find(params[:event_registration_id])
      if event_registration
        RendezvousMailer.delay.registration_confirmation(event_registration)
        flash_notice('Email sent')
      else
        flash_notice('No registration found')
      end
      redirect_to :root
    end

    private

      # Create pdf and send acknowledgement emails
      def send_confirmation_emails
        # filename = "#{@event_registration.invoice_number}.pdf"
        # registration_pdf = ::WickedPdf.new.pdf_from_string(
        #   render_to_string('registrations/show', layout: 'layouts/registration_mailer', encoding: 'UTF-8')
        # )
        # save_dir =  Rails.root.join('public','registrations')
        # save_path = Rails.root.join('public','registrations', filename)
        # File.open(save_path, 'wb') do |file|
        #   file << registration_pdf
        # end
        RendezvousMailer.delay.registration_confirmation(@event_registration)
        # RendezvousMailer.delay.registration_notification(@event_registration) unless Rails.env.development?
      end


      # Only allows admins and owners to see registration
      def owner_or_admin
        unless (current_user.id == Registration.find(params[:id]).user_id) || (current_user.has_role? :admin)
          flash_alert 'Sorry, you must be an admin to see that.'
          redirect_to :root
        end
      end

      def handle_mailchimp(user)
        action = user.receive_mailings? ? 'subscribe' : 'unsubscribe'
        response = user.mailchimp_action(action)
        if response[:status] == :ok
          flash_notice 'Your user information and mailing list status were updated.'
        else
          flash_alert 'Your user information was updated, but there was a problem updating your mailing list status.'
          flash_alert response[:message]
        end
        response
      end

      def event_registration_params
        params.require(:event_registration).permit(
          :number_of_adults,
          :number_of_seniors,
          :number_of_children,
          :registration_fee,
          :donation,
          :total,
          :year,
          :paid_amount,
          :paid_method,
          :paid_date,
          :status,
          :invoice_number,
          :user_id,
          { attendees_attributes:
            [:id, :name, :attendee_age, :volunteer, :sunday_dinner, :_destroy]
          },
          {:user_attributes=>
            [:id, :email, :password, :password_confirmation, :first_name, :last_name, :address1, :address2, :city, :state_or_province, :postal_code, :country, :receive_mailings, :citroenvie,
              {vehicles_attributes:
                [:id, :year, :marque, :other_marque, :model, :other_model, :other_info, :_destroy]
              }
            ]
          }
        )
      end

      def event_registration_user_params
        params[:user] = params[:event_registration][:user_attributes]
        params.require(:user).permit(
          [:id, :email, :password, :password_confirmation, :first_name, :last_name, :address1, :address2, :city, :state_or_province, :postal_code, :country, :receive_mailings, :citroenvie,
            {vehicles_attributes:
              [:id, :year, :marque, :other_marque, :model, :other_model, :other_info, :_destroy]
            }
          ]
        )
      end
  end
end

