# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :attendee do
    name "MyString"
    adult_or_child "MyString"
    volunteer false
    sunday_dinner false
  end
end
