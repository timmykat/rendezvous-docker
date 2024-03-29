# Read about factories at https://github.com/thoughtbot/factory_bot

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
