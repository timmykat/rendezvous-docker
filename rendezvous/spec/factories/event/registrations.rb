# Read about factories at https://github.com/thoughtbot/factory_bot

# == Schema Information
#
# Table name: registrations
#
#  id                  :integer          not null, primary key
#  annual_answer       :string(255)
#  balance             :decimal(8, 2)    default(0.0), not null
#  created_by_admin    :boolean          default(FALSE), not null
#  donation            :decimal(8, 2)    default(0.0)
#  events              :text(65535)
#  invoice_number      :string(255)
#  is_admin_created    :boolean          default(FALSE), not null
#  lake_cruise_fee     :decimal(8, 2)    default(0.0)
#  lake_cruise_number  :integer          default(0), not null
#  late_period         :boolean          default(FALSE)
#  number_of_adults    :integer          default(0)
#  number_of_children  :integer          default(0)
#  number_of_seniors   :integer          default(0)
#  number_of_youths    :integer          default(0)
#  paid_amount         :decimal(8, 2)    default(0.0)
#  paid_date           :datetime
#  paid_method         :string(255)
#  refunded            :decimal(8, 2)    default(0.0), not null
#  registration_fee    :decimal(8, 2)    default(0.0)
#  status              :string(255)      default("pending")
#  step                :string(255)      default("creating")
#  sunday_lunch_number :integer          default(0), not null
#  total               :decimal(8, 2)    default(0.0)
#  vendor_fee          :decimal(6, 2)
#  year                :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#  cc_transaction_id   :string(255)
#  user_id             :integer
#
# Indexes
#
#  index_registrations_on_balance            (balance)
#  index_registrations_on_cc_transaction_id  (cc_transaction_id)
#  index_registrations_on_invoice_number     (invoice_number)
#  index_registrations_on_paid_amount        (paid_amount)
#  index_registrations_on_paid_date          (paid_date)
#  index_registrations_on_paid_method        (paid_method)
#  index_registrations_on_refunded           (refunded)
#  index_registrations_on_status             (status)
#  index_registrations_on_year               (year)
#
FactoryBot.define do
  factory :registration, class: Event::Registration do
    user
    attendee
    number_of_adults { 2 }
    number_of_youths { 1 }
    number_of_children { 0 }
    lake_cruise_number { 3 }
    paid_amount { 250.00 }
    paid_method { :credit_card }
  end
end
