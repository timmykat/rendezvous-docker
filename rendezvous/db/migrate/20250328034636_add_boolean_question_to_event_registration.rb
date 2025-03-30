class AddBooleanQuestionToEventRegistration < ActiveRecord::Migration[7.1]
  def change
    add_column :registrations, :annual_answer, :string
  end
end
