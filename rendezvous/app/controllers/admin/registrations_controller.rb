class Admin::RegistrationsController < AdminController

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
    redirect_to event_registration_path(@event_registration)
  end
  
  def cancel
    @event_registration = Event::Registration.find(params[:id])
    
    # Delete all attendees
    @event_registration.attendees.destroy_all
    @event_registration.number_of_adults = 0
    @event_registration.number_of_seniors = 0
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
    @event_registration.status = 'cancelled'
    
    @event_registration.save!
    flash_notice "This registration was cancelled. Amount to be refunded: $#{@refund}"
    redirect_to event_registration_path(@event_registration)
  end
  
  
  private
  
    def registration_update_params
      params.require(:registration).permit(
        :id,
        :number_of_adults,
        :number_of_seniors,
        :number_of_children,
        :registration_fee,
        :total,
        :status,
        { attendees_attributes:
          [:id, :name, :attendee_age, :volunteer, :sunday_dinner, :_destroy]
        }
      )
    end
  
end

