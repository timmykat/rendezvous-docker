# == Schema Information
#
# Table name: annual_questions
#
#  id         :bigint           not null, primary key
#  question   :string(255)
#  year       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_annual_questions_on_year  (year)
#
class AnnualQuestion < ApplicationRecord

  RESPONSES = ['Sorry, not interested', 'Maybe', 'Definitely'].freeze
end
