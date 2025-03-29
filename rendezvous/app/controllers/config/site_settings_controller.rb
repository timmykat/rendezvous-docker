class Config::SiteSettingsController < ApplicationController

  layout "admin"

  before_action :require_admin

  def get
    @instance = Config::SiteSetting.instance
  end

  def update
    @instance = Config::SiteSetting.instance
    if !@instance.update(site_settings_params)
      flash_alert "There was a problem updating the site settings"
    else 
      flash_notice "The site settings were updated"
    end
    redirect_to admin_dashboard_path
  end

  private
    def site_settings_params
      params.require(:config_site_setting).permit(
        :registration_fee,
        :opening_day,
        :days_duration,
        :registration_open,
        :registration_open_date,
        :user_testing      
      )
    end
end