class AddDefaultsToRegistrationColumns < ActiveRecord::Migration[7.2]

  def up
    # Decimals
    set_default_and_backfill %i[
        donation
        lake_cruise_fee
        paid_amount
        refunded
        registration_fee
        total
      ], 0.0

    # Integers
    set_default_and_backfill %i[
        number_of_adults
        number_of_youths
        number_of_children
        number_of_seniors
        lake_cruise_number
        sunday_lunch_number
      ], 0

    # Enums
    change_column_default :registrations, :status, 'pending'
    change_column_default :registrations, :step, 'creating'
  end

  def set_default_and_backfill(fields, default)
    fields.each do |field|
      change_column_default :registrations, field, default
      Event::Registration.where("#{field} IS NULL").update_all(field => default)
    end
  end
end
