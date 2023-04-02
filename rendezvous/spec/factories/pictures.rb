# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :picture do
    user { '' }
    image { 'MyString' }
    caption { 'MyString' }
    credit { 'MyString' }
    year { 1986 }
  end
end
