# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :attendee do
    name "Andre Citroen"
    attendee_age "adult"
    volunteer false
    sunday_dinner false
  end
end
