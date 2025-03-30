class Picture < ApplicationRecord
  belongs_to :user
  
  mount_uploader :image, ImageUploader
  
  def self.front_page_set
    Picture.limit(8).order("RAND()")
  end
  
  def initialize(attributes = {})
    attributes[:year] ||= Time.now.year.to_s
    super(attributes)
  end
end
