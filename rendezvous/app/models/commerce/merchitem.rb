module Commerce
  class Merchitem < ActiveRecord::Base
    
    validates :sku, presence: true, on: :update

    validates :size, inclusion: { in: Rails.configuration.rendezvous[:merchandise][:sizes] }

    belongs_to :merchandise

  end
end