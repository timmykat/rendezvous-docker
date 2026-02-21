# == Schema Information
#
# Table name: cart_items
#
#  id           :bigint           not null, primary key
#  number       :integer          default(1)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  merchitem_id :bigint
#  purchase_id  :bigint
#
# Indexes
#
#  index_cart_items_on_merchitem_id  (merchitem_id)
#  index_cart_items_on_purchase_id   (purchase_id)
#
module Commerce
  class CartItem < ApplicationRecord
    belongs_to :purchase,  class_name: 'Commerce::Purchase'
    belongs_to :merchitem, optional: true
  end
end
