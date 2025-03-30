class AddSquareEnvironmentToSiteSettings < ActiveRecord::Migration[7.1]
  def change
    add_column :site_settings, :square_environment, :string
    add_column :site_settings, :refund_date, :date
  end
end
