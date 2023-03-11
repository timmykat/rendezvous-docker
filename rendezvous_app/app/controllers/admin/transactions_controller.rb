class Admin::TransactionsController < AdminController
  def create
    registration = Registration.find(params[:registration_id])
    transaction = Transaction.new(transaction_params)

    # Set transaction amount for refund to be negative
    if transaction.transaction_type == 'refund'
      transaction.amount = -transaction.amount
    end
    
    registration.paid_amount ||= 0.0
    
    if (transaction.amount + registration.paid_amount) < 0.0
      flash_alert_now "You probably don't want to refund more than the person has paid..."
      render 'admin/registrations/edit'
      return
    end
    
    registration.transactions << transaction
    registration.paid_amount += transaction.amount
    if (registration.total - registration.paid_amount).abs < 0.10
      registration.status = 'complete'
    end
    
    if !registration.save
      flash_alert 'There was a problem creating the transaction.'
    else
      flash_notice 'The transaction was successfully created.'
    end
        
    redirect_to edit_admin_registration_path(registration)
        
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
