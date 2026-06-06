class AddDisplayVoteButtonToSiteSetting < ActiveRecord::Migration[7.2]
  def change
    add_column :site_settings, :display_vote_button, :boolean, null: false, default: false
  end
end
