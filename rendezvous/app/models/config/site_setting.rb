# == Schema Information
#
# Table name: site_settings
#
#  id                   :bigint           not null, primary key
#  debug_dates          :boolean
#  registration_is_open :boolean
#  square_environment   :string(255)
#  voting_on            :boolean          default(FALSE)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
class Config::SiteSetting < ApplicationRecord

  private_class_method :new

  @instance = nil

  def self.instance
    @instance ||= Config::SiteSetting.first_or_create
  end

  def self.reload_instance
    @instance = Config::SiteSetting.first  # Reload to ensure updated data
  end
  
end
