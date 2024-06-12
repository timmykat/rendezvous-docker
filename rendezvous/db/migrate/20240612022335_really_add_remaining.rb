class ReallyAddRemaining < ActiveRecord::Migration[7.1]
  def change
    add_column :merchitems, :remaining, :integer
  end
end
