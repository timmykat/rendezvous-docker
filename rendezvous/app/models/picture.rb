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
class Picture < ApplicationRecord
  belongs_to :user
  
  mount_uploader :image, ImageUploader
  
  def self.front_page_set
    Picture.limit(8).order("RAND()")
  end
  
  def initialize(attributes = {})
    attributes[:year] ||= Date.current.year.to_s
    super(attributes)
  end
end
