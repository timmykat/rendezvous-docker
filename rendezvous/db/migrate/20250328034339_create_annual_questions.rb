class CreateAnnualQuestions < ActiveRecord::Migration[7.1]
  def change
    create_table :annual_questions do |t|
      t.integer :year
      t.string :question

      t.timestamps
    end
    add_index :annual_questions, :year
  end
end
