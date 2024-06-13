module Commerce
  class CartItem < ActiveRecord::Base
    belongs_to :purchases
  end
end