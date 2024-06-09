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
      @title = 'Editing the registration for ' + user.full_name
      flash_notice(user.full_name + ' has already created a registration')
    else
      @title = 'Creating a registration for ' + user.full_name
      @event_registration = Event::Registration.new
      @event_registration.onsite = true
      @event_registration.user = user
      @event_registration.attendees.build
      @event_registration.transactions.build
    end  
  end

  def create
    user_id = params[:event_registration][:user_attributes][:id]
    user = User.find(user_id)
    params[:event_registration][:user_attributes] = nil

    @event_registration = Event::Registration.new
    @event_registration.user = user
    transaction = Transaction.new
    transaction.update(transaction_params)
    unless transaction.transaction_type == 'none'
      @event_registration.transactions << transaction
    end

    begin
      if !@event_registration.save
        Rails.logger.debug "*** The registration wasn't saved"
        Rails.logger.debug @event_registration.errors.full_messages
      end
    rescue Exception => e
      Rails.logger.debug "*** First save problem with user"
      Rails.logger.debug e.inspect
      Rails.logger.debug @event_registration,inspect 
    end

    begin
      if !@event_registration.update(create_registration_params)
        Rails.logger.debug "*** The registration wasn't updated"
        Rails.logger.debug @event_registration.errors.full_messages
      end
    rescue Exception => e
      Rails.logger.debug "*** Update problemwith real event params"
      Rails.logger.debug e.inspect
      Rails.logger.debug @event_registration,inspect 
    end

    @event_registration.total = @event_registration.registration_fee + @event_registration.donation
    
    @event_registration.paid_amount = 0.0
    if !@event_registration.transactions.blank?
      transaction = @event_registration.transactions.first
      @event_registration.paid_amount =  transaction.amount
      @event_registration.paid_method = transaction.transaction_method
    end
    
    if @event_registration.paid_amount == @event_registration.total
      @event_registration.paid_date = Time.now
      @event_registration.status = 'complete'
    else
      @event_registration.status = 'payment due'
    end
    @event_registration.invoice_number = Event::Registration.invoice_number

    begin
      @event_registration.save
    rescue Exception => e
      Rails.logger.debug e.inspect
      flash_notice = 'There was a problem creating the registration'
      redirect_to admin_index_path, notice: flash_notice
      return
    end

    flash_notice = 'Registration was successfully created'
    redirect_to admin_event_registration_path(@event_registration.id), notice: flash_notice
  end

  def new_with_email 
    session[:admin_user] = true
    user = User.find_by_email(params[:user][:email])

    Rails.logger.info user.blank? ? "No user for #{params[:user][:email]}" : "Found user #{user.full_name}"

    if user.blank?
      user = User.new(new_user_params)
      # Set a password for the user
      password = (65 + rand(26)).chr + 6.times.inject(''){|a, b| a + (97 + rand(26)).chr} + (48 + rand(10)).chr
      user.password = password
      user.password_confirmation = password
      Rails.logger.info "Saving user #{user.full_name}"
      if !user.save
        flash_alert_now 'There was a problem saving the user.'
        flash_alert_now user.errors.full_messages.to_sentence        
      else
        Rails.logger.info "Successful"
      end
    else
      flash_notice 'This user already exists'
    end

    @title = 'Creating a registration onsite for user ' + user.full_name
    @event_registration = Event::Registration.new
    @event_registration.onsite = true
    @event_registration.user = user
    @event_registration.attendees.build
  end

  def create_with_email
    user_id = params[:event_registration][:user_attributes][:id]
    user = User.find(user_id)
    params[:event_registration][:user_attributes] = nil

    @event_registration = Event::Registration.new
    @event_registration.user = user

    if !@event_registration.update(registration_update_params)
      flash_alert_now @event_registration.errors.full_messages
      redirect_to '/', alert: flash_alert
      return
    end

    @event_registration.paid_amount = 0.0
    @event_registration.invoice_number = Event::Registration.invoice_number

    if !@event_registration.save
      flash_alert_now @event_registration.errors.full_messages
      redirect_to '/', alert: flash_alert
    else
      flash_notice = 'Registration was successfully created'
      redirect_to payment_event_registration_path(@event_registration), notice: flash_notice
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
      event_registration = Event::Registration.find(params[:id])
      if event_registration
        RendezvousMailer.registration_confirmation(event_registration).deliver_later
      else
        flash_notice('No registration found')
      end
      redirect_to admin_index_path
    else
      redirect_to :root
    end
  end
  
  private
    def new_user_params
      params.require(:user).permit(
        :email,
        :first_name,
        :last_name
      )
    end

    def registration_update_params
      params.require(:event_registration).permit(
        :id,
        :onsite,
        :number_of_adults,
        :number_of_children,
        :registration_fee,
        :donation,
        :total,
        :status,
        :year,
        { attendees_attributes:
          [:id, :name, :attendee_age, :volunteer, :sunday_dinner, :_destroy]
        }
      )
    end

    def transaction_params
      params[:transaction] = params[:event_registration][:transactions_attributes]['0']
      params[:transaction].permit( 
        [:transaction_method, :transaction_type, :amount, :cc_transaction_id]
      )
    end

    def create_registration_params
      params.require(:event_registration).permit(
        :id,
        :onsite,
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
        { attendees_attributes:
          [:id, :name, :attendee_age, :volunteer, :sunday_dinner, :_destroy]
        },
        :transaction_id,
        { transaction_attributes:
          [:id, :transaction_method, :transaction_type, :amount, :cc_transaction_id, :_destroy]
        },
        :user_id,
        { user_attributes:
          [:id, :email, :password, :password_confirmation, :first_name, :last_name, :address1, :address2, :city, :state_or_province, :postal_code, :country, :citroenvie]
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

