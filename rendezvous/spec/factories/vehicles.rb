# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :vehicle do
    registrant
    marque "Citroen"
    model "D (early)"
    year 1963
  end
end
