class AddLoginOnBooleanToSiteSettings < ActiveRecord::Migration[7.2]
  def change
    add_column :site_settings, :login_on, :boolean, default: false
  end
end
