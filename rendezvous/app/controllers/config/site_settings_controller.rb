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
      @instance.registration_fee ||= 80.0
      @instance.days_duration ||= 3
      @instance.square_environment ||= 'SANDBOX'
      @instance.vendor_fee ||= 300.0
    end

    def site_settings_params
      params.require(:config_site_setting).permit(
        :registration_fee,
        :opening_day,
        :days_duration,
        :refund_date,
        :show_registration_override,
        :registration_is_open,
        :registration_close_date,
        :square_environment,
        :user_testing,
        :vendor_fee,
        :voting_on     
      )
    end
end