class UpgradeRegistrationAmountStorageTypes < ActiveRecord::Migration[7.2]
  
  AMOUNT_COLUMNS = [
    :registration_fee,
    :lake_cruise_fee,
    :donation,
    :total,
    :paid_amount
  ]
  
  def up
    change_table :registrations, bulk: true do |t|
      AMOUNT_COLUMNS.each do |c|
        t.change c, :decimal, precision: 8, scale: 2
      end
    end
  end

  def down
    change_table :registrations, bulk: true do |t|
      AMOUNT_COLUMNS.each do |c|
        if c == :total
          t.change c, :float, limit: 24 
        else
          t.change c, :decimal, precision: 6, scale: 2
        end
      end
    end
  end
end