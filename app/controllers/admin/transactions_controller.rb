class Admin::TransactionsController < AdminController
  def create
    @rendezvous_registration = RendezvousRegistration.find(params[:rendezvous_registration_id])
    transaction = Transaction.new(transaction_params)
    if !transaction.save
      flash_alert_now 'We were unable to save that transaction'
      render 'admin/rendezvous_registrations/show'
      return
    end
    
    @rendezvous_registration.transactions << transaction
    
    # Update the registration values
    if transaction.transaction_type == 'payment'
      balance_change = transaction.amount
    elsif transaction.transaction_type == 'refund'
      balance_change = -transaction.amount
    end
    
    @rendezvous_registration.paid_amount ||= 0.0
    
    if (balance_change + @rendezvous_registration.paid_amount) < 0.0
      flash_alert_now "You probably don't want to refund more than the person has paid..."
      render 'admin/rendezvous_registrations/show'
      return
    end
 
    @rendezvous_registration.paid_amount += balance_change
    
    if (@rendezvous_registration.total - @rendezvous_registration.paid_amount).abs < 0.10
      @rendezvous_registration.status = 'complete'
    end
    
    if !@rendezvous_registration.save
      flash_alert 'There was a problem creating the transaction.'
    else
      flash_notice 'The transaction was successfully created.'
    end
    redirect_to admin_rendezvous_registration_path(@rendezvous_registration)
        
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
