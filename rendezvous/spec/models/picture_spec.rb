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
require 'rails_helper'

RSpec.describe Picture, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
