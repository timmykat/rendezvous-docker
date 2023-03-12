class AddTransactionTable < ActiveRecord::Migration
  def up
    create_table :transactions do |t|
      t.string  :transaction_method
      t.string  :transaction_type
      t.string  :cc_transaction_id
      t.decimal :amount, :precision => 6, :scale => 2, :default => 0.00
      
      t.belongs_to :rendezvous_registration
      
      t.timestamps
    end
    
    add_index :transactions, :transaction_method
    add_index :transactions, :transaction_type
    add_index :transactions, :cc_transaction_id
    
    # Insert pre-existing data (only for credit cards, not for cheques)
    RendezvousRegistration.all.each do |reg|
      if reg.paid_method == 'credit card' && reg.status == 'complete'
        transaction = Transaction.new(
          :transaction_method         => 'credit card',
          :transaction_type           => 'payment',
          :cc_transaction_id          => reg.cc_transaction_id,
          :amount                     => reg.paid_amount,
          :rendezvous_registration_id => reg.id
        )
        if !transaction.save!
          puts transaction.errors.full_messages.to_sentence
        else  
          puts "Transaction saved for registration #{reg.id}"
          puts transaction.cc_transaction_id
          puts transaction.amount
        end
      end
    end   
  end
  
  def down
    drop_table :transactions
  end
end
