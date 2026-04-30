class AddFeePeriodToRegistrations < ActiveRecord::Migration[7.2]
  def change
    add_column :registrations, :fee_period, :string, null: false, default: 'early'
    add_index :registrations, :fee_period
  end
end
