class Admin::RegistrationsController < AdminController

  def show
    @registration = Event::Registration.includes(:user, :transactions, :attendees).find(params[:id])
    render 'admin/registrations/show'
  end

  def edit
    @registration = Event::Registration.includes(:user, :transactions, :attendees).find(params[:id])
    @registration.transactions.build
    @transaction = Transaction.new
    
    render 'admin/registrations/edit'
  end
  
  def update
    @registration = Event::Registration.find(params[:id])
    
    if @registration.update(registration_update_params)
    
      # Update values that depend on the registration fee
      donation = @registration.donation || 0.0
      @registration.total = @registration.registration_fee + donation
      @registration.save!
      flash_notice 'The registration was updated.'
    else
      flash_alert 'There was a problem updating the registration.'
      flash_alert @registration.errors.full_messages.to_sentence
    end
    redirect_to admin_registration_path(@registration)
  end
  
  def cancel
    @registration = Event::Registration.find(params[:id])
    
    # Delete all attendees
    @registration.attendees.destroy_all
    @registration.number_of_adults = 0
    @registration.number_of_seniors = 0
    @registration.number_of_children = 0
    
    # Set registration fee to 0.0
    if !@registration.paid_amount.nil?
      @refund = @registration.paid_amount
      if !@registration.donation.nil? && (@registration.donation < @refund)
        @refund = @refund - @registration.donation
      end
    else 
      @refund = 0.0
    end
    
    @registration.total  -= @registration.registration_fee
    @registration.registration_fee = 0.0
    
    # Set status
    @registration.status = 'cancelled'
    
    @registration.save!
    flash_notice "This registration was cancelled. Amount to be refunded: $#{@refund}"
    redirect_to admin_registration_path(@registration)
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

