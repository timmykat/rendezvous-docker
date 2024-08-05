module Commerce
  class CartItem < ActiveRecord::Base
    belongs_to :purchase,  class_name: 'Commerce::Purchase'
    belongs_to :merchitem, optional: true
  end
end