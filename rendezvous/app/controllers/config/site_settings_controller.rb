class Config::SiteSettingsController < ApplicationController

  layout "admin_layout"

  before_action :require_admin

  def get
    @instance = Config::SiteSetting.instance
    set_defaults
  end

  def update
    @instance = Config::SiteSetting.instance
    if @instance.update(site_settings_params)
      Config::SiteSetting.reload_instance
      flash_notice "The site settings were updated"
    else
      flash_alert "There was a problem updating the site settings"
    end
    redirect_to admin_dashboard_path
  end

  private

  def set_defaults
    @instance.square_environment ||= 'SANDBOX'
  end

  def site_settings_params
    params.require(:config_site_setting).permit(
      :debug_test_date,
      :debug_dates,
      :login_on,
      :registration_is_open,
      :square_environment,
      :voting_on
    )
  end
end
