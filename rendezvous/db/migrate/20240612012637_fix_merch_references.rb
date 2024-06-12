class FixMerchReferences < ActiveRecord::Migration[7.1]
  def change
    remove_column :merchandise, :merchitems_id, :integer
    add_column :merchitems, :merchandise_id, :integer
  end
end
