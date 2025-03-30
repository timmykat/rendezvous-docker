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
