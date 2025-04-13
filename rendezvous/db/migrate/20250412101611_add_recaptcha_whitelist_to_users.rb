class AddRecaptchaWhitelistToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :recaptcha_whitelisted, :boolean
  end
end
