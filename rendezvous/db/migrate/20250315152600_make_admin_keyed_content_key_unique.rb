class MakeAdminKeyedContentKeyUnique < ActiveRecord::Migration[7.1]
  def change
      # Remove the existing index (if it's not unique)
      remove_index :admin_keyed_contents, :key if index_exists?(:admin_keyed_contents, :key)

      # Add the unique index
      add_index :admin_keyed_contents, :key, unique: true
  end
end
