class AddStepToRegistration < ActiveRecord::Migration[7.2]
  def up
    add_column :registrations, :step, :string, default: 'create'

    execute <<-SQL
      UPDATE registrations
      SET status = CASE
        WHEN status IN ('complete', 'payment due') THEN status
        WHEN status REGEXP 'cancel' THEN 'cancelled'
        ELSE 'in progress'
      END
    SQL

    execute <<-SQL
      UPDATE registrations
      SET step = CASE
        WHEN status IN ('complete', 'cancelled') THEN NULL
        ELSE 'review'
      END
    SQL
  end

  def down
    remove_column :registrations, :step
  end
end
