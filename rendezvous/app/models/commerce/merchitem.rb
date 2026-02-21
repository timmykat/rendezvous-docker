# == Schema Information
#
# Table name: merchitems
#
#  id                 :bigint           not null, primary key
#  remaining          :integer
#  size               :string(255)
#  sku                :string(255)
#  starting_inventory :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  merchandise_id     :integer
#
# Indexes
#
#  index_merchitems_on_sku  (sku)
#
module Commerce
  class Merchitem < ApplicationRecord
    
    validates :sku, presence: true, on: :update

    validates :size, inclusion: { in: Rails.configuration.commerce[:merchandise][:sizes] }

    belongs_to :merchandise
    has_many :cart_items

  end
end
