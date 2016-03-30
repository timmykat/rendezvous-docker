class MakeAdultAttendeeDefault < ActiveRecord::Migration
  def change
    change_column_default :attendees, :adult_or_child, 'adult'
  end
end
