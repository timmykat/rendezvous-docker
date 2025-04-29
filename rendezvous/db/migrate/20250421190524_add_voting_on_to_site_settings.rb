class AddVotingOnToSiteSettings < ActiveRecord::Migration[7.1]
  def change
    add_column :site_settings, :voting_on, :boolean, default: false
  end
end
