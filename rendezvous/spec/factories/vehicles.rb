# Read about factories at https://github.com/thoughtbot/factory_bot

# == Schema Information
#
# Table name: vehicles
#
#  id         :integer          not null, primary key
#  code       :string(255)
#  for_sale   :boolean
#  marque     :string(255)
#  model      :string(255)
#  other_info :text(65535)
#  year       :string(255)
#  user_id    :integer
#
# Indexes
#
#  index_vehicles_on_code                       (code)
#  index_vehicles_on_for_sale                   (for_sale)
#  index_vehicles_on_marque                     (marque)
#  index_vehicles_on_marque_and_model           (marque,model)
#  index_vehicles_on_marque_and_year_and_model  (marque,year,model)
#  index_vehicles_on_model                      (model)
#  index_vehicles_on_user_id                    (user_id)
#  index_vehicles_on_year                       (year)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :vehicle do
    registrant
    marque { 'Citroen'  }
    model { 'D (early)'  }
    year { 1963 }
  end
end
