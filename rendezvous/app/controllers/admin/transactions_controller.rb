class Admin::TransactionsController < AdminController
  def create
    event_registration = Event::Registration.find(params[:registration_id])
    transaction = Transaction.new(transaction_params)

    # Set transaction amount for refund to be negative
    if transaction.transaction_type == 'refund'
      transaction.amount = -transaction.amount
    end
    
    event_registration.paid_amount ||= 0.0
    
    if (transaction.amount + event_registration.paid_amount) < 0.0
      flash_alert_now "You probably don't want to refund more than the person has paid..."
      render 'admin/registrations/edit'
      return
    end
    
    event_registration.transactions << transaction
    event_registration.paid_amount += transaction.amount
    if (event_registration.total - event_registration.paid_amount).abs < 0.10
      if transaction.transaction_type == 'refund'
        event_registration.status = 'cancelled - settled'
      else
        event_registration.status = 'complete'
      end
    end
    
    if !event_registration.save
      flash_alert 'There was a problem creating the transaction.'
    else
      flash_notice 'The transaction was successfully created'
    end
        
    redirect_to edit_event_registration_path(event_registration)
        
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
