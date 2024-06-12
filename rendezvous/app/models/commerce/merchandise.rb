module Commerce
  class Merchandise < ActiveRecord::Base
    
    attribute :sku, presence: true
    attribute :description, presence: true
    attribute :sale_price, presence: true

    has_many :merchitems, dependent: :destroy
    accepts_nested_attributes_for :merchitems, reject_if: :all_blank, allow_destroy: true

    def total_inventory
      inventory = 0
      merchitems.each do |item|
        inventory += item.inventory if !item.inventory.nil?
      end
      return inventory
    end

    def total_remaining
      remaining = 0
      merchitems.each do |item|
        remaining += item.remaining if !item.remaining.nil?
      end
      return remaining
    end
  end
end