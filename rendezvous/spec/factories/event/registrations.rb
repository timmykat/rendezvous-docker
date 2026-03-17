# Read about factories at https://github.com/thoughtbot/factory_bot

# == Schema Information
#
# Table name: registrations
#
#  id                  :integer          not null, primary key
#  annual_answer       :string(255)
#  created_by_admin    :boolean          default(FALSE), not null
#  donation            :decimal(6, 2)
#  events              :text(65535)
#  invoice_number      :string(255)
#  is_admin_created    :boolean          default(FALSE), not null
#  lake_cruise_fee     :decimal(6, 2)
#  lake_cruise_number  :integer          default(0), not null
#  number_of_adults    :integer
#  number_of_children  :integer
#  number_of_seniors   :integer
#  number_of_youths    :integer
#  paid_amount         :decimal(6, 2)
#  paid_date           :datetime
#  paid_method         :string(255)
#  registration_fee    :decimal(6, 2)
#  status              :string(255)
#  sunday_lunch_number :integer          default(0), not null
#  total               :float(24)
#  vendor_fee          :decimal(6, 2)
#  year                :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#  cc_transaction_id   :string(255)
#  user_id             :integer
#
# Indexes
#
#  index_registrations_on_cc_transaction_id  (cc_transaction_id)
#  index_registrations_on_invoice_number     (invoice_number)
#  index_registrations_on_paid_amount        (paid_amount)
#  index_registrations_on_paid_date          (paid_date)
#  index_registrations_on_paid_method        (paid_method)
#  index_registrations_on_status             (status)
#  index_registrations_on_year               (year)
#
FactoryBot.define do
  factory :event_registration do
    registrant
    attendee
    number_of_adults { 2 }
    number_of_children { 0 }
    amount { 100.00 }
    paid_method { 'credit card' }
  end
end
