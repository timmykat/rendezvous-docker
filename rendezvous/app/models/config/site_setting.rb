# == Schema Information
#
# Table name: site_settings
#
#  id                   :bigint           not null, primary key
#  debug_dates          :boolean
#  debug_test_date      :date
#  login_on             :boolean          default(FALSE)
#  registration_is_open :boolean
#  square_environment   :string(255)
#  voting_on            :boolean          default(FALSE)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
class Config::SiteSetting < ApplicationRecord

  validate :display_vote_button_requires_voting_on

  private_class_method :new

  @instance = nil

  def self.instance
    @instance ||= Config::SiteSetting.first_or_create
  end

  def self.reload_instance
    @instance = Config::SiteSetting.first  # Reload to ensure updated data
  end

  private

  def display_vote_button_requires_voting_on
    return unless display_vote_button?
    return if voting_on?

    errors.add(:display_vote_button, 'can only be enabled when voting is on')
  end

end
