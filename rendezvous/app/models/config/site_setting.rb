# == Schema Information
#
# Table name: site_settings
#
#  id                         :bigint           not null, primary key
#  days_duration              :integer
#  opening_day                :date
#  refund_date                :date
#  registration_close_date    :date
#  registration_fee           :decimal(6, 2)
#  registration_is_open       :boolean
#  show_registration_override :boolean
#  square_environment         :string(255)
#  user_testing               :boolean
#  vendor_fee                 :decimal(6, 2)
#  voting_on                  :boolean          default(FALSE)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
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
