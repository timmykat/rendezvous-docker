class Admin::Event::RegistrationsController < AdminController

  def new    
    session[:admin_user] = true
    user = User.find(params[:id])
    if (user.blank?)
      @title = 'No user found'
      return
    end

    # Check for existing reservation
    @event_registration = user.registrations.current.first
    if !@event_registration.blank?
      @title = 'Editing registration for ' + user.full_name
      flash_notice(user.full_name + ' has already created a registration')
    else
      @title = 'ADMIN: creating a registration for ' + user.full_name
      @event_registration = Event::Registration.new
      @event_registration.user = user
      @event_registration.attendees.build
      @event_registration.transactions.build
    end
  end

  def create
    data = params[:event_registration]
    fee = data[:registration_fee]
    params[:event_registration][:total] = fee + data[:donation]
    payment = data[:transactions].first
    params[:event_registration][:paid_amount] = payment[:amount]
    params[:event_registration][:paid_method] = payment[:transaction_method]
    
    if params[:event_registration][:paid_amount] == params[:event_registration][:total]
      params[:event_registration][:paid_date] = Time.now
      params[:event_registration][:status] = 'complete'
    else
      params[:event_registration][:status] = 'payment due'
    end

    params[:event_registration][:invoice_number] = Registration.invoice_number

    @event_registration = Event::Registration.new(event_registration_params)

    if @event_registration.save
      flash_notice = 'Registration was successfully create'
      redirect_to admin_event_registration_path(@event_registration), notice: flash_notice
    else
      flash_notice = 'There was a problem creating the registration'
      redirect_to admin_index_path, notice: flash_notice
    end
  end

  def show
    @event_registration = Event::Registration.includes(:user, :transactions, :attendees).find(params[:id])
  end

  def edit
    @event_registration = Event::Registration.includes(:user, :transactions, :attendees).find(params[:id])
    @event_registration.transactions.build
    @transaction = Transaction.new
  end
  
  def update
    @event_registration = Event::Registration.find(params[:id])
    
    if @event_registration.update(registration_update_params)
    
      # Update values that depend on the registration fee
      donation = @event_registration.donation || 0.0
      @event_registration.total = @event_registration.registration_fee + donation
      @event_registration.save!
      flash_notice 'The registration was updated.'
    else
      flash_alert 'There was a problem updating the registration.'
      flash_alert @event_registration.errors.full_messages.to_sentence
    end
    redirect_to event_registration_path(@event_registration.id)
  end

  def delete
    @event_registration = Event::Registration.find(params[:id])
    @event_registration.destroy
    flash_notice 'The registration has been deleted'
    redirect_to admin_index_path
  end
  
  def cancel
    @event_registration = Event::Registration.find(params[:id])
    
    # Delete all attendees
    @event_registration.attendees.destroy_all
    @event_registration.number_of_adults = 0
    @event_registration.number_of_children = 0
    
    # Set registration fee to 0.0
    if !@event_registration.paid_amount.nil?
      @refund = @event_registration.paid_amount
      if !@event_registration.donation.nil? && (@event_registration.donation < @refund)
        @refund = @refund - @event_registration.donation
      end
    else 
      @refund = 0.0
    end
    
    @event_registration.total  -= @event_registration.registration_fee
    @event_registration.registration_fee = 0.0
    
    # Set status
    if @refund > 0.0
      @event_registration.status = 'cancelled - needs refund'
    else
      @event_registration.status = 'cancelled - settled'
    end
    
    @event_registration.save!
    flash_notice "This registration was cancelled. Amount to be refunded: $#{@refund}"
    redirect_to event_registration_path(@event_registration)
  end
  
  def send_confirmation_email
    if current_user.admin?
      Rails.logger.debug "*** Registration ID: " + params[:id]
      event_registration = Event::Registration.find(params[:id])
      if event_registration
        Rails.logger.debug "*** Sending registration email to " + event_registration.user.email
        RendezvousMailer.registration_confirmation(event_registration).deliver_later
        Rails.logger.debug "*** Email sent"
      else
        flash_notice('No registration found')
      end
      redirect_to admin_index_path
    else
      redirect_to :root
    end
  end
  
  private
    def registration_update_params
      params.require(:event_registration).permit(
        :id,
        :number_of_adults,
        :number_of_children,
        :registration_fee,
        :total,
        :status,
        { attendees_attributes:
          [:id, :name, :attendee_age, :volunteer, :sunday_dinner, :_destroy]
        }
      )
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
        :status,
        :invoice_number,
        :user_id,
        { attendees_attributes:
          [:id, :name, :attendee_age, :volunteer, :sunday_dinner, :_destroy]
        },
        { transactions_attributes:
          [:transaction_method, :transaction_type, :amount, :cc_transaction_id]
        },
        {:user_attributes=>
          [:id, :email, :password, :password_confirmation, :first_name, :last_name, :address1, :address2, :city, :state_or_province, :postal_code, :country, :citroenvie,
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
        [:id, :email, :password, :password_confirmation, :first_name, :last_name, :address1, :address2, :city, :state_or_province, :postal_code, :country, :citroenvie,
          {vehicles_attributes:
            [:id, :year, :marque, :other_marque, :model, :other_model, :other_info, :_destroy]
          }
        ]
      )
    end
  
end

