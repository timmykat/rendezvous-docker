class Admin::RendezvousRegistrationsController < AdminController
  def show
    @rendezvous_registration = RendezvousRegistration.includes(:user, :transactions, :attendees).find(params[:id])
    @rendezvous_registration.transactions.build
    @transaction = Transaction.new
    
    render 'admin/rendezvous_registrations/show'
  end
  
  def update
    @rendezvous_registration = RendezvousRegistration.find(params[:id])
    
    if @rendezvous_registration.update(rendezvous_registration_update_params)
    
      # Update values that depend on the registration fee
      donation = @rendezvous_registration.donation || 0.0
      @rendezvous_registration.total = @rendezvous_registration.registration_fee + donation
      @rendezvous_registration.save!
      flash_notice 'The registration was updated.'
    else
      binding.pry
      flash_alert 'There was a problem updating the registration.'
      flash_alert @rendezvous_registration.errors.full_messages.to_sentence
    end
    redirect_to admin_rendezvous_registration_path(@rendezvous_registration)
  end
  
  
  private
  
    def rendezvous_registration_update_params
      params.require(:rendezvous_registration).permit(
        :id,
        :number_of_adults,
        :number_of_children,
        :registration_fee,
        :total,
        :status,
        { :attendees_attributes =>
          [:id, :name, :adult_or_child, :volunteer, :sunday_dinner, :_destroy]
        }
      )
    end
  
end

