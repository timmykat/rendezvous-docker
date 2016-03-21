class RendezvousRegistrationsController < ApplicationController

  before_action :require_admin, :only => :index
  before_action :authenticate_user!, :except => [:new]
  
  def new
  
    if user_signed_in?
      @rendezvous_registration = current_user.rendezvous_registrations.current.first
      if !@rendezvous_registration.blank?
        flash[:notice] = "You've already created a registration."
        redirect_to edit_user_path(current_user)
        return
      end
    end
  
    @rendezvous_registration = RendezvousRegistration.new
    @rendezvous_registration.attendees.build
    if user_signed_in?
      @rendezvous_registration.user = current_user
    else
      @rendezvous_registration.build_user
    end
    @rendezvous_registration.user.vehicles.build
    render 'registration_form'
  end

  def create

    # Create the registration and update or create the user - 
    # complicated because Rails doesn't gracefully handle nested associations where the nest is a parent
    if user_signed_in?
      user = User.find(current_user.id)
      user.update(rendezvous_registration_user_params)
      params[:rendezvous_registration][:user_id] = current_user.id
      params[:rendezvous_registration][:user_attributes] = nil
    end
    
    # Set total to registration fee. Donation happens later
    params[:rendezvous_registration][:total] = params[:rendezvous_registration][:registration_fee]

    @rendezvous_registration = RendezvousRegistration.new(rendezvous_registration_params)
    @rendezvous_registration.invoice_number = RendezvousRegistration.invoice_number
    
    if !@rendezvous_registration.save
      flash[:alert] = 'There was a problem creating your registration: '
      flash[:alert] += @rendezvous_registration.errors.full_messages.to_sentence
      render 'registration_form'
    else
      if !user_signed_in?
        sign_in(@rendezvous_registration.user)
      end
      redirect_to review_rendezvous_registration_path(@rendezvous_registration)
    end    
  end
  
  def edit
    
    @rendezvous_registration = RendezvousRegistration.find(params[:id])
    render 'registration_form'
  end

  def update
    @rendezvous_registration = RendezvousRegistration.find(params[:id])
    
    if @rendezvous_registration.update(rendezvous_registration_params)
      redirect_to :show, :notice => 'Your registration was updated.'
    else
      redirect_to edit_rendezvous_registration_path(@rendezvous_registration), :alert => 'There was a problem updating your registration.'
    end
  end
  
  def review
    @rendezvous_registration = RendezvousRegistration.find(params[:id])
  end
  
  def payment
    begin
      @rendezvous_registration = RendezvousRegistration.find(params[:id])
      @app_data[:clientToken] =  Braintree::ClientToken.generate
      @app_data[:total] = @rendezvous_registration.total
      @credit_connection = true
    rescue e
      @credit_connection = false
      flash[:alert] = "We're sorry but the connection to our credit card processor isn't available. Please pay later, or register now and choose pay by check."
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
        @rendezvous_registration.save!
        Mailer.registration_acknowledgement(@rendezvous_registration).deliver_later
        Mailer.registration_notification(@rendezvous_registration).deliver_later
        redirect_to @rendezvous_registration, :notice => 'You are now registered for the Rendezvous! You should receive a confirmation by email shortly.'
        return
      elsif result.errors
        flash[:alert] = result.message
        render rendzvous_registration_path(@rendezvous_registration)
        return
      end
    end 
    
    # Set the paid amounts
    params[:rendezvous_registration][:amount] = params[:rendezvous_registration][:amount].to_f
    if paid_with_credit_card
      params[:rendezvous_registration][:paid_amount] = params[:rendezvous_registration][:amount]
      params[:rendezvous_registration][:paid_method] = 'credit card'
    else
      params[:rendezvous_registration][:paid_amount] = 0.00
    end
    
    # Update the registration
    if !@rendezvous_registration.update_attributes(rendezvous_registration_params)
      flash[:alert] = @rendzvous.errors.messages.to_sentence
      render 'payment'
    else
      Mailer.registration_acknowledgement(@rendezvous_registration).deliver_later
      Mailer.registration_notification(@rendezvous_registration).deliver_later
      redirect_to rendezvous_registration_path(@rendezvous_registration)
    end
  end
  
  def index
    @rendezvous_registrations = RendezvousRegistration.all
  end
  
  def show
    @rendezvous_registration = RendezvousRegistration.find(params[:id])
  end
  
  
  private
      
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
        {:user_attributes=>
          [:id, :email, :password, :password_confirmation, :first_name, :last_name, :address1, :address2, :city, :state_or_province, :postal_code, :country,
            {:vehicles_attributes => 
              [:id, :year, :marque, :other_marque, :model, :other_model, :other_info, :_destroy]
            }
          ]
        }
      )
    end
    
    def rendezvous_registration_user_params
      params[:user] = params[:rendezvous_registration][:user_attributes]
      params.require(:user).permit(
        [:id, :email, :password, :password_confirmation, :first_name, :last_name, :address1, :address2, :city, :state_or_province, :postal_code, :country,
          {:vehicles_attributes => 
            [:id, :year, :marque, :other_marque, :model, :other_model, :other_info, :_destroy]
          }
        ]
      )
    end
end
