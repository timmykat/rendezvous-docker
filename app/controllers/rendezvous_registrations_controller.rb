class RendezvousRegistrationsController < ApplicationController

  before_action :require_admin, :only => [:index]
  before_action :authenticate_user!, :except => [:new]
  before_action :owner_or_admin, :only => [:show]
  before_action :set_cache_buster

  skip_before_action :verify_authenticity_token, :only => [:show]

  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
  
  def new     
    if user_signed_in? && !session[:admin_user]
      @rendezvous_registration = current_user.rendezvous_registrations.current.first
      if !@rendezvous_registration.blank?
        flash_notice("You've already created a registration.")
        redirect_to edit_user_path(current_user)
        return
      end
    end
  
    @rendezvous_registration = RendezvousRegistration.new
    @rendezvous_registration.attendees.build
    
    if user_signed_in? && !session[:admin_user]
      @rendezvous_registration.user = current_user
    else
      @rendezvous_registration.build_user
    end
    @rendezvous_registration.user.vehicles.build
    render 'registration_form'
  end
  
  def create
  
    # Create or update the user
    if user_signed_in? && !session[:admin_user]
      user = User.find(current_user.id)      
      if !user.update(rendezvous_registration_user_params) 
        flash_alert 'There was a problem saving the user.'
        flash_alert user.errors.full_messages.to_sentence
        redirect_to register_path and return
      end
    else
      user = User.find_by_email(params[:rendezvous_registration][:user_attributes][:email])
      if user.blank?
        password = (65 + rand(26)).chr + 6.times.inject(''){|a, b| a + (97 + rand(26)).chr} + (48 + rand(10)).chr
        params[:rendezvous_registration][:user_attributes][:password] = password
        params[:rendezvous_registration][:user_attributes][:password_confirmation] = password
        user = User.new(rendezvous_registration_user_params)
        if !user.save
          flash_alert_now 'There was a problem saving your user information.'
          flash_alert_now user.errors.full_messages.to_sentence
          @rendezvous_registration = RendezvousRegistration.new
          @rendezvous_registration.attendees.build
          render 'registration_form' and return  
        end
      end
    end
    
    # Done updating the user so remove those parameters
    params[:rendezvous_registration][:user_id] = user.id
    params[:rendezvous_registration][:user_attributes] = nil
    
    
    # Set total to registration fee. Donation happens in payment
    params[:rendezvous_registration][:total] = params[:rendezvous_registration][:registration_fee]
    
    @rendezvous_registration = RendezvousRegistration.new(rendezvous_registration_params)
    @rendezvous_registration.invoice_number = RendezvousRegistration.invoice_number
    
    if !@rendezvous_registration.save
      flash_alert_now('There was a problem creating your registration.')
      flash_alert_now @rendezvous_registration.errors.full_messages.to_sentence
      render 'registration_form' and return
    else
      handle_mailchimp(@rendezvous_registration.user)     
      sign_in(@rendezvous_registration.user) unless (session[:user_admin] || user_signed_in?)
      redirect_to review_rendezvous_registration_path(@rendezvous_registration)
    end    
  end
  
  def edit
    @rendezvous_registration = RendezvousRegistration.find(params[:id])
    render 'registration_form'
  end

  def update
    @rendezvous_registration = RendezvousRegistration.find(params[:id])
    email = true
    
    if params[:review]
      email = false
      user = @rendezvous_registration.user
      mailchimp_init = user.receive_mailings
    
      user.update(rendezvous_registration_user_params)
    
      handle_mailchimp(user) unless user.receive_mailings == mailchimp_init
      params[:rendezvous_registration][:user_id] = user.id
      params[:rendezvous_registration][:user_attributes] = nil
    
      # Set total to registration fee. Donation happens in payment
      params[:rendezvous_registration][:total] = params[:rendezvous_registration][:registration_fee]
      
      if @rendezvous_registration.update(rendezvous_registration_params)
        flash_notice 'The registration was updated.'
        send_registration_update_emails(type) if email
        redirect_to review_rendezvous_registration_path(@rendezvous_registration)
        return
      else
        flash_alert 'There was a problem updating the registration.'
        flash_alert @rendezvous_registration.errors.full_messages.to_sentence
        redirect_to edit_rendezvous_registration_path(@rendezvous_registration)
        return
      end
    
    elsif params[:cancellation]
      refund = @rendezvous_registration.registration_fee
      if @rendezvous_registration.paid_method ==  'credit card'
        
        # Get the transaction
        begin
          get_transaction = Braintree::Transaction.find(@rendezvous_registration.cc_transaction_id)
        rescue Braintree::NotFoundError => e
          flash_alert 'We could not find a transaction that matches what we have on record. Please contact us through the web form.'
          redirect_to root_path
        end
        
        # Refund or void depending on the state
        if get_transaction.status == 'settled' || get_transaction.status == 'settling'
          result = Braintree::Transaction.refund(@rendezvous_registration.cc_transaction_id)
          if result.success?
            flash_notice "The registration portion of your payment has been refunded. Any donations are non-refundable."
            flash_notice "You will receive a confirmation email shortly."
            operation = 'refund'
          else
            flash_alert_now "There was a problem refunding your registration."
            flash_alert_now result.message
            render :update_completed
            return
          end
        else
          result = Braintree::Transaction.void(@rendezvous_registration.cc_transaction_id)
          if result.success?
            flash_notice "Your entire registration payment, including any donation, has been voided."
            flash_notice "You will receive a confirmation email shortly."
            operation = 'void'
          else
            flash_alert_now "There was a problem refunding your registration."
            flash_alert_now result.message
            render :update_completed
            return
          end
        
          # All transactions taken care of, fully cancelled
          params[:rendezvous_registration][:status] = 'cancelled'
        end
        
      elsif  @rendezvous_registration.paid_method ==  'check'
        # Check must be written before the registration is fully cancelled
        params[:rendezvous_registration][:status] = 'cancelled - refund pending'
      end
        
      # Update the registration and transaction records
      params[:rendezvous_registration][:number_of_adults] = 0
      params[:rendezvous_registration][:number_of_children] = 0
      params[:rendezvous_registration][:registration_fee] = 0.0
      if operation == 'void'
        params[:rendezvous_registration][:paid_amount]  = 0.0
        params[:rendezvous_registration][:total]        = 0.0
      else
        params[:rendezvous_registration][:paid_amount]  = @rendezvous_registration.paid_amount - refund
        params[:rendezvous_registration][:total]        = @rendezvous_registration.total - refund
      end
    
      if @rendezvous_registration.update(rendezvous_registration_params)
        flash_notice 'The registration was updated.'
        send_registration_update_emails('cancellation') if email
        redirect_to review_rendezvous_registration_path(@rendezvous_registration)
        return
      else
        flash_alert 'There was a problem updating the registration.'
        flash_alert @rendezvous_registration.errors.full_messages.to_sentence
        redirect_to edit_rendezvous_registration_path(@rendezvous_registration)
        return
      end

    elsif params[:rendezvous_registration][:status] == 'updating'
      attendee_change = params[:rendezvous_registration][:number_of_adults].to_i - @rendezvous_registration.number_of_adults 
      if attendee_change < 0
      
        # Refund is a positive number
        refund =  - attendee_change * Rails.configuration.rendezvous[:fees][:registration][:adult]

        if @rendezvous_registration.paid_method ==  'credit card'       
          # Get the transaction
          begin
            result = Braintree::Transaction.find(@rendezvous_registration.cc_transaction_id)
          rescue Braintree::NotFoundError => e
            flash_alert 'We could not find a transaction that matches what we have on record. Please contact us through the web form.'
            redirect_to root_path
            return
          end
        
          # Refund or hold if still authorizing
          if result.status == 'settled' || result.status == 'settling'
            result = Braintree::Transaction.refund(@rendezvous_registration.cc_transaction_id, refund.to_s)
            if result.success?
              flash_notice "We have refunded you the registration fee for #{attendee_change.abs} adult(s)"
              flash_notice "You will receive a confirmation email shortly."
              operation = 'refund'
            else
              flash_alert_now "There was a problem with the partial refund of your registration fee."
              flash_alert_now result.message
              render :update_completed
              return
            end
          else
            flash_alert "Your credit card transaction is still authorizing, please try later."
            redirect_to rendezvous_registration_path(@rendezvous_registration)
          end
        end   
      elsif attendee_change > 0
        additional_charge = attendee_change * Rails.configuration.rendezvous[:fees][:registration][:adult]
        if params[:rendezvous_registration][:paid_method] == 'credit card' && !params[:payment_method_nonce].blank? 
          braintree_transaction_params = {
            :order_id             => "#{@rendezvous_registration.invoice_number}-UPDATE",
            :amount               => additional_charge,
            :payment_method_nonce => params[:payment_method_nonce],
            :customer             => {
              :first_name               => @rendezvous_registration.user.first_name,
              :last_name                => @rendezvous_registration.user.last_name,
              :email                    => @rendezvous_registration.user.email,
            },
            :billing               => {
              :first_name               => @rendezvous_registration.user.first_name,
              :last_name                => @rendezvous_registration.user.last_name,
              :street_address           => @rendezvous_registration.user.address1,
              :extended_address         => @rendezvous_registration.user.address2,
              :locality                 => @rendezvous_registration.user.city,
              :region                   => @rendezvous_registration.user.state_or_province,
              :postal_code              => @rendezvous_registration.user.postal_code,
              :country_code_alpha2      => @rendezvous_registration.user.country
            },
            :options => {
              :submit_for_settlement => true
            },
          }
      
          result = Braintree::Transaction.sale(braintree_transaction_params)
      
          if result.success?
            @rendezvous_registration.paid_amount = @rendezvous_registration.total + additional_charge
            @rendezvous_registration.registration_fee = @rendezvous_registration.registration_fee + additional_charge
            
            # Keep original transaction ID as the id associated with the registration, but create new transaction
            @rendezvous_registration.cc_transaction_id = result.transaction.id
        
            # Create a new transaction
            @rendezvous_registration.transactions << Transaction.new(
              :transaction_method => 'credit card',
              :transaction_type => 'updated payment',
              :cc_transaction_id => result.transaction.id,
              :amount => additional_charge
            )
            
            @rendezvous_registration.status = 'complete'
             
            if @rendezvous_registration.save!
              send_registration_update_emails('update')
              flash_notice 'Your registration for the #{Time.now.year} Rendezvous has been updated. You should receive a confirmation by email shortly.'
              redirect_to @rendezvous_registration
              return
            else
              flash_alert_now "There was a problem updating your registration."
              flash_alert_now @rendezvous_registration.errors.messages.to_sentence
              render :update_completed
              return
            end
          elsif result.errors
            flash_alert 'There was a problem with your credit card payment.'
            flash_alert result.message
            redirect_to update_completed_rendezvous_registration_path(@rendezvous_registration)
            return
          end
        end 
        
      end
      
      if @rendezvous_registration.update(rendezvous_registration_params)
        flash_notice 'The registration was updated.'
        send_registration_update_emails('update') if email
        redirect_to review_rendezvous_registration_path(@rendezvous_registration)
        return
      else
        flash_alert 'There was a problem updating the registration.'
        flash_alert @rendezvous_registration.errors.full_messages.to_sentence
        redirect_to edit_rendezvous_registration_path(@rendezvous_registration)
        return
      end        
    end    
  end
  
  def update_completed
    @rendezvous_registration = RendezvousRegistration.find(params[:id])
    begin
      @app_data[:clientToken] =  Braintree::ClientToken.generate
      @app_data[:registration_fee] = @rendezvous_registration.registration_fee
      @credit_connection = true
    rescue BraintreeError => e
      @credit_connection = false
      flash_alert("We're sorry but the connection to our credit card processor isn't available. Please update later.")
      flash_alert e.inspect
      redirect_to update_completed_rendezvous_registration_path(@rendezvous_registration)
    end
    @app_data[:current_registration] = {
      :attendees => {
        :adults => @rendezvous_registration.number_of_adults,
        :children => @rendezvous_registration.number_of_children
      },
      :registration_fee => @rendezvous_registration.registration_fee
    }
  end

  def review
    @rendezvous_registration = RendezvousRegistration.find(params[:id])
  end
  
  def payment
    @rendezvous_registration = RendezvousRegistration.find(params[:id])
    begin
      @app_data[:clientToken] =  Braintree::ClientToken.generate
      @app_data[:registration_fee] = @rendezvous_registration.registration_fee
      @credit_connection = true
    rescue BraintreeError => e
      @credit_connection = false
      flash_alert("We're sorry but the connection to our credit card processor isn't available. Please pay later, or register now and choose pay by check.")
      flash_alert e.inspect
      redirect_to payment_rendezvous_registration_path(@rendezvous_registration)
    end
  end

  
  def complete
    @rendezvous_registration = RendezvousRegistration.find(params[:id])
    @rendezvous_registration.update(rendezvous_registration_params) 

    # If this is a credit card transaction, set the customer and billing attributes
    # (have to do it now, in case this is an existing user and the user attributes are removed laster
    
    if params[:rendezvous_registration][:paid_method] == 'credit card' && !params[:payment_method_nonce].blank? 
      braintree_transaction_params = {
        :order_id             => @rendezvous_registration.invoice_number,
        :amount               => @rendezvous_registration.total,
        :payment_method_nonce => params[:payment_method_nonce],
        :customer             => {
          :first_name               => @rendezvous_registration.user.first_name,
          :last_name                => @rendezvous_registration.user.last_name,
          :email                    => @rendezvous_registration.user.email,
        },
        :billing               => {
          :first_name               => @rendezvous_registration.user.first_name,
          :last_name                => @rendezvous_registration.user.last_name,
          :street_address           => @rendezvous_registration.user.address1,
          :extended_address         => @rendezvous_registration.user.address2,
          :locality                 => @rendezvous_registration.user.city,
          :region                   => @rendezvous_registration.user.state_or_province,
          :postal_code              => @rendezvous_registration.user.postal_code,
          :country_code_alpha2      => @rendezvous_registration.user.country
        },
        :options => {
          :submit_for_settlement => true
        },
      }
      
      result = Braintree::Transaction.sale(braintree_transaction_params)
      
      if result.success?
        @rendezvous_registration.paid_amount = @rendezvous_registration.total
        @rendezvous_registration.paid_method = 'credit card'
        @rendezvous_registration.cc_transaction_id = result.transaction.id
        @rendezvous_registration.paid_date = Time.new
        @rendezvous_registration.status = 'complete'
        
        # Create a new transaction
        @rendezvous_registration.transactions << Transaction.new(
          :transaction_method => 'credit card',
          :transaction_type => 'payment',
          :cc_transaction_id => result.transaction.id,
          :amount => @rendezvous_registration.total
        )
        if @rendezvous_registration.save!
          send_registration_success_emails
          flash_notice 'You are now registered for the Rendezvous! You should receive a confirmation by email shortly.'
          redirect_to @rendezvous_registration
          return
        else
          flash_alert "There was a problem saving your registration."
          flash_alert @rendezvous_registration.errors.messages.to_sentence
        end
      elsif result.errors
        flash_alert 'There was a problem with your credit card payment.'
        flash_alert result.message
        redirect_to payment_rendezvous_registration_path(@rendezvous_registration)
        return
      end
    end 
    
    # Set the paid amounts
    params[:rendezvous_registration][:total] = params[:rendezvous_registration][:total].to_f
    if params[:rendezvous_registration][:paid_method] == 'credit card'
      params[:rendezvous_registration][:paid_amount] = params[:rendezvous_registration][:total]
    else
      params[:rendezvous_registration][:paid_amount] = 0.00
    end
    
    # Update the registration
    if !@rendezvous_registration.update_attributes(rendezvous_registration_params)
      flash_alert 'There was a problem completing your registration.'
      flash_alert @rendezvous_registration.errors.full_messages.to_sentence
      redirect_to payment_rendezvous_registration_path(@rendezvous_registration)
    else
      send_registration_success_emails
      flash_notice 'You are now registered for the Rendezvous! You should receive a confirmation by email shortly.'
      redirect_to rendezvous_registration_path(@rendezvous_registration)
    end
  end
    
  def index
    @rendezvous_registrations = RendezvousRegistration.all
  end
  
  def show
    @rendezvous_registration = RendezvousRegistration.find(params[:id])
  end
  
  def destroy
    @rendezvous_registration = RendezvousRegistration.find(params[:id])
    @rendezvous_registration.destroy
    flash_notice('Your registration has been deleted.')
    redirect_to user_path(current_user)
  end
  
  
  private
    
    # Create pdf and send acknowledgement emails
    def send_registration_success_emails
      filename = "#{@rendezvous_registration.invoice_number}.pdf"
      registration_pdf = ::WickedPdf.new.pdf_from_string(
        render_to_string('rendezvous_registrations/show', :layout => 'layouts/registration_mailer', :encoding => 'UTF-8')
      )
      save_dir =  Rails.root.join('public','registrations')   
      save_path = Rails.root.join('public','registrations', filename)
      File.open(save_path, 'wb') do |file|
        file << registration_pdf
      end
      Mailer.registration_acknowledgement(@rendezvous_registration).deliver_later
      Mailer.registration_notification(@rendezvous_registration).deliver_later unless Rails.env.development?
    end
    
    def send_registration_update_emails(type)
      filename = "#{@rendezvous_registration.invoice_number}-#{type == 'cancellation' ? 'CANCELLED' : 'UPDATE'}.pdf"
      registration_change_pdf = ::WickedPdf.new.pdf_from_string(
        render_to_string('rendezvous_registrations/update_receipt', :layout => 'layouts/registration_mailer', :encoding => 'UTF-8')
      )
      save_dir =  Rails.root.join('public','registrations')   
      save_path = Rails.root.join('public','registrations', filename)
      File.open(save_path, 'wb') do |file|
        file << registration_change_pdf
      end
      type_and_method = "#{type} - #{@rendezvous_registration.paid_method}"
      Mailer.registration_update(type_and_method, @rendezvous_registration).deliver_later
    end
    
  
    # Only allows admins and owners to see registration
    def owner_or_admin
      unless (current_user.id == RendezvousRegistration.find(params[:id]).user_id) || (current_user.has_role? :admin)
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
  
    def rendezvous_registration_params
      params.require(:rendezvous_registration).permit(
        :number_of_adults,
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
          [:id, :name, :adult_or_child, :volunteer, :sunday_dinner, :_destroy]
        },
        { :user_attributes =>
          [:id, :email, :password, :password_confirmation, :first_name, :last_name, :address1, :address2, :city, :state_or_province, :postal_code, :country, :receive_mailings, :citroenvie,
            {:vehicles_attributes => 
              [:id, :year, :marque, :other_marque, :model, :other_model, :other_info, :_destroy]
            }
          ]
        },
        { :transactions_attributes => 
          [ :id, :transaction_method, :transaction_type, :cc_transaction_id, :amount ]
        }
      )
    end
    
    def rendezvous_registration_user_params
      params[:user] = params[:rendezvous_registration][:user_attributes]
      params.require(:user).permit(
        [:id, :email, :password, :password_confirmation, :first_name, :last_name, :address1, :address2, :city, :state_or_province, :postal_code, :country, :receive_mailings, :citroenvie,
          {:vehicles_attributes => 
            [:id, :year, :marque, :other_marque, :model, :other_model, :other_info, :_destroy]
          }
        ]
      )
    end
end
