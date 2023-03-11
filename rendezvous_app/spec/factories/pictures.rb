# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :picture do
    user ""
    image "MyString"
    caption "MyString"
    credit "MyString"
    year 1
  end
end
