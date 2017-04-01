class Admin::TransactionsController < AdminController
  def create
    rendezvous_registration = RendezvousRegistration.find(params[:rendezvous_registration_id])
    transaction = Transaction.new(transaction_params)

    # Set transaction amount for refund to be negative
    if transaction.transaction_type == 'refund'
      transaction.amount = -transaction.amount
    end
    
    rendezvous_registration.paid_amount ||= 0.0
    
    if (transaction.amount + rendezvous_registration.paid_amount) < 0.0
      flash_alert_now "You probably don't want to refund more than the person has paid..."
      render 'admin/rendezvous_registrations/edit'
      return
    end
    
    rendezvous_registration.transactions << transaction
    rendezvous_registration.paid_amount += transaction.amount
    if (rendezvous_registration.total - rendezvous_registration.paid_amount).abs < 0.10
      rendezvous_registration.status = 'complete'
    end
    
    if !rendezvous_registration.save
      flash_alert 'There was a problem creating the transaction.'
    else
      flash_notice 'The transaction was successfully created.'
    end
        
    redirect_to edit_admin_rendezvous_registration_path(rendezvous_registration)
        
  end
  
  private
    def transaction_params
      params.require(:transaction).permit(
        :transaction_method, 
        :transaction_type, 
        :cc_transaction_id, 
        :amount
      )
    end
end
