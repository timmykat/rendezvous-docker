module Commerce
  class CartItem < ApplicationRecord
    belongs_to :purchase,  class_name: 'Commerce::Purchase'
    belongs_to :merchitem, optional: true
  end
end