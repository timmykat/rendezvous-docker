# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  address1               :string(255)
#  address2               :string(255)
#  citroenvie             :boolean
#  city                   :string(255)
#  country                :string(255)
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  first_name             :string(255)
#  is_admin_created       :boolean          default(FALSE)
#  is_testing             :boolean          default(FALSE)
#  last_active            :datetime
#  last_name              :string(255)
#  login_token            :string(255)
#  login_token_sent_at    :datetime
#  postal_code            :string(255)
#  provider               :string(255)
#  recaptcha_whitelisted  :boolean
#  receive_mailings       :boolean          default(TRUE)
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string(255)
#  role_mask              :integer
#  roles_mask             :integer
#  state_or_province      :string(255)
#  uid                    :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  square_customer_id     :string(255)
#
# Indexes
#
#  index_users_on_citroenvie            (citroenvie)
#  index_users_on_country               (country)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_first_name            (first_name)
#  index_users_on_last_active           (last_active)
#  index_users_on_last_name             (last_name)
#  index_users_on_login_token           (login_token) UNIQUE
#  index_users_on_provider              (provider)
#  index_users_on_receive_mailings      (receive_mailings)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_roles_mask            (roles_mask)
#  index_users_on_square_customer_id    (square_customer_id)
#  index_users_on_state_or_province     (state_or_province)
#  index_users_on_uid                   (uid)
#
require 'rails_helper'

RSpec.describe User, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
