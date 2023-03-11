class RegistrationsController < ApplicationController

  before_action :check_cutoff, :only => [:new, :create, :complete, :edit]
  before_action :require_admin, :only => [:index]
  before_action :authenticate_user!, :except => [:new, :welcome]
  before_action :owner_or_admin, :only => [:show]
  before_action :set_cache_buster

  skip_before_action :verify_authenticity_token, :only => [:show]

  def check_cutoff
    unless (current_user.has_any_role? :admin, :tester) || Time.now >= Rails.configuration.rendezvous[:registration_window][:open] && Time.now <= Rails.configuration.rendezvous[:registration_window][:close]
      flash_alert("Online registration is now closed. You may register on arrival at the Rendezvous.")
      redirect_to :root
    end
  end

  def get_payment_token
    puts "PAYMENT TOKEN " +  ENV['BRAINTREE_PAYMENT_TOKEN']
    render plain:  ENV['BRAINTREE_PAYMENT_TOKEN'], content_type: 'text/plain'
  end

  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  def new

    @title = 'Registration - Start'

    if user_signed_in? && !session[:admin_user]
      @registration = current_user.registrations.current.first
      if !@registration.blank?
        flash_notice("You've already created a registration.")
        redirect_to edit_user_path(current_user)
        return
      end
    end

    @registration = Registration.new
    @registration.attendees.build

    if user_signed_in? && !session[:admin_user]
      @registration.user = current_user
    else
      @registration.build_user
    end
    @registration.user.vehicles.build
    render 'registration_form'
  end

  def create

    # Create or update the user
    if user_signed_in? && !session[:admin_user]
      user = User.find(current_user.id)
      if !user.update(registration_user_params)
        flash_alert 'There was a problem saving the user.'
        flash_alert user.errors.full_messages.to_sentence
        redirect_to register_path and return
      end
    else
      user = User.find_by_email(params[:registration][:user_attributes][:email])
      if user.blank?
        password = (65 + rand(26)).chr + 6.times.inject(''){|a, b| a + (97 + rand(26)).chr} + (48 + rand(10)).chr
        params[:registration][:user_attributes][:password] = password
        params[:registration][:user_attributes][:password_confirmation] = password
        user = User.new(registration_user_params)
        if !user.save
          flash_alert_now 'There was a problem saving your user information.'
          flash_alert_now user.errors.full_messages.to_sentence
          @registration = Registration.new
          @registration.attendees.build
          render 'registration_form' and return
        end
      end
    end

    # Done updating the user so remove those parameters
    params[:registration][:user_id] = user.id
    params[:registration][:user_attributes] = nil


    # Set total to registration fee. Donation happens in payment
    params[:registration][:total] = params[:registration][:registration_fee]

    @registration = Registration.new(registration_params)
    @registration.invoice_number = Registration.invoice_number

    if !@registration.save
      flash_alert_now('There was a problem creating your registration.')
      flash_alert_now @registration.errors.full_messages.to_sentence
      render 'registration_form' and return
    else
      handle_mailchimp(@registration.user)
      sign_in(@registration.user) unless (session[:user_admin] || user_signed_in?)
      redirect_to review_registration_path(@registration)
    end
  end

  def edit
    @title = 'Edit Registration'

    @registration = Registration.find(params[:id])
    render 'registration_form'
  end

  def update

    @registration = Registration.find(params[:id])
    user = @registration.user
    mailchimp_init = user.receive_mailings

    user.update(registration_user_params)

    handle_mailchimp(user) unless user.receive_mailings == mailchimp_init
    params[:registration][:user_id] = user.id
    params[:registration][:user_attributes] = nil

    # Set total to registration fee. Donation happens in payment
    params[:registration][:total] = params[:registration][:registration_fee]

    if @registration.update(registration_params)
      flash_notice 'The registration was updated.'
      redirect_to review_registration_path(@registration)
    else
      flash_alert 'There was a problem updating the registration.'
      flash_alert @registration.errors.full_messages.to_sentence
      redirect_to edit_registration_path(@registration)
    end
  end

  def review
    @title = 'Review Registration Information'
    @registration = Registration.find(params[:id])
    @registration.status = 'in review'
    @registration.save!
  end

  def payment
    @title = 'Registration - Payment'
    begin
      @title = 'Registration - Payment'
      @registration = Registration.find(params[:id])
      @registration.status = 'payment due'
      @app_data[:registration_fee] = @registration.registration_fee
      @credit_connection = true
    rescue Braintree::BraintreeError => e
      @credit_connection = false
      flash_alert("We're sorry but the connection to our credit card processor isn't available. Please pay later, or register now and choose pay by check.")
      flash_alert e.inspect
      # redirect_to payment_registration_path(@registration)
    end
  end


  def complete
    @title = 'Complete Registration'
    @registration = Registration.find(params[:id])
    @registration.update(registration_params)

    # If this is a credit card transaction, set the customer and billing attributes
    # (have to do it now, in case this is an existing user and the user attributes are removed laster

    if params[:registration][:paid_method] == 'credit card' && !params[:payment_method_nonce].blank?
      braintree_transaction_params = {
        :order_id             => @registration.invoice_number,
        :amount               => @registration.total,
        :payment_method_nonce => params[:payment_method_nonce],
        :customer             => {
          :first_name               => @registration.user.first_name,
          :last_name                => @registration.user.last_name,
          :email                    => @registration.user.email,
        },
        :billing               => {
          :first_name               => @registration.user.first_name,
          :last_name                => @registration.user.last_name,
          :street_address           => @registration.user.address1,
          :extended_address         => @registration.user.address2,
          :locality                 => @registration.user.city,
          :region                   => @registration.user.state_or_province,
          :postal_code              => @registration.user.postal_code,
          :country_code_alpha3      => @registration.user.country
        },
        :options => {
          :submit_for_settlement => true
        },
      }

      gateway = Braintree::Gateway.new(
        :environment => Braintree::Configuration.environment,
        :merchant_id => Braintree::Configuration.merchant_id,
        :public_key => Braintree::Configuration.public_key,
        :private_key => Braintree::Configuration.private_key,
      )

      result = gateway.transaction.sale(braintree_transaction_params)

      if result.success?

        # Create a new transaction
        @registration.transactions << Transaction.new(
          :transaction_method => 'credit card',
          :transaction_type => 'payment',
          :cc_transaction_id => result.transaction.id,
          :amount => @registration.total
        )

        @registration.paid_amount = @registration.total
        @registration.paid_method = 'credit card'
        @registration.cc_transaction_id = result.transaction.id
        @registration.paid_date = Time.new
        @registration.status = 'complete'
        @registration.save!
        send_confirmation_emails
        flash_notice 'You are now registered for the Rendezvous! You should receive a confirmation by email shortly.'
        redirect_to vehicles_registration_path(@registration)
        return
      elsif result.errors
        flash_alert 'There was a problem with your credit card payment.'
        flash_alert result.message
        redirect_to payment_registration_path(@registration)
        return
      end
    end

    # Set the paid amounts
    params[:registration][:total] = params[:registration][:total].to_f
    if params[:registration][:paid_method] == 'credit card'
      params[:registration][:paid_amount] = params[:registration][:total]
    else
      params[:registration][:paid_amount] = 0.00
    end

    # Update the registration
    if !@registration.update_attributes(registration_params)
      flash_alert 'There was a problem completing your registration.'
      flash_alert @registration.errors.full_messages.to_sentence
      redirect_to payment_registration_path(@registration)
    else
      send_confirmation_emails
      flash_notice 'You are now registered for the Rendezvous! You should receive a confirmation by email shortly.'
      redirect_to vehicles_registration_path(@registration)
#      redirect_to registration_path(@registration)
    end
  end

  def vehicles
    @title = 'Vehicle Information'

    @registration = Registration.find(params[:id])
    @user = @registration.user
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
    redirect_to user_path(current_user)
  end

  def welcome

  end

  def send_email
    registration_id = params[:registration_id]
    registration = Registration.find(registration_id)
    if registration
      Mailer.registration_confirmation(registration).deliver
      flash_notice('Email sent')
    else
      flash_notice('No registration found')
    end
    redirect_to :root
  end

  private

    # Create pdf and send acknowledgement emails
    def send_confirmation_emails
      # filename = "#{@registration.invoice_number}.pdf"
      # registration_pdf = ::WickedPdf.new.pdf_from_string(
      #   render_to_string('registrations/show', :layout => 'layouts/registration_mailer', :encoding => 'UTF-8')
      # )
      # save_dir =  Rails.root.join('public','registrations')
      # save_path = Rails.root.join('public','registrations', filename)
      # File.open(save_path, 'wb') do |file|
      #   file << registration_pdf
      # end
      Mailer.registration_confirmation(@registration).deliver_later
      # Mailer.registration_notification(@registration).deliver_later unless Rails.env.development?
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

    def registration_params
      params.require(:registration).permit(
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
        { :attendees_attributes =>
          [:id, :name, :attendee_age, :volunteer, :sunday_dinner, :_destroy]
        },
        {:user_attributes=>
          [:id, :email, :password, :password_confirmation, :first_name, :last_name, :address1, :address2, :city, :state_or_province, :postal_code, :country, :receive_mailings, :citroenvie,
            {:vehicles_attributes =>
              [:id, :year, :marque, :other_marque, :model, :other_model, :other_info, :_destroy]
            }
          ]
        }
      )
    end

    def registration_user_params
      params[:user] = params[:registration][:user_attributes]
      params.require(:user).permit(
        [:id, :email, :password, :password_confirmation, :first_name, :last_name, :address1, :address2, :city, :state_or_province, :postal_code, :country, :receive_mailings, :citroenvie,
          {:vehicles_attributes =>
            [:id, :year, :marque, :other_marque, :model, :other_model, :other_info, :_destroy]
          }
        ]
      )
    end
end
