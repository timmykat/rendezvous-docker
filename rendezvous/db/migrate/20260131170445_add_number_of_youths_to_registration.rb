class AddNumberOfYouthsToRegistration < ActiveRecord::Migration[7.1]
  def change
    add_column :registrations, :number_of_youths, :integer
  end
end
