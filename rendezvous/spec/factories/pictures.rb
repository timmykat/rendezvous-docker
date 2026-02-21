# Read about factories at https://github.com/thoughtbot/factory_bot

# == Schema Information
#
# Table name: pictures
#
#  id         :integer          not null, primary key
#  caption    :string(255)
#  credit     :string(255)
#  image      :string(255)
#  year       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#
FactoryBot.define do
  factory :picture do
    user { '' }
    image { 'MyString' }
    caption { 'MyString' }
    credit { 'MyString' }
    year { 1986 }
  end
end
