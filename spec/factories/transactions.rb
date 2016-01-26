# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :transaction do
    transaction_id "MyString"
    customer_id "MyString"
  end
end
