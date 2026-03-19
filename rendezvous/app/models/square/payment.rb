module Square
  class Payment < ApplicationRecord
    belongs_to :registration, class_name: 'Event::Registration', optional: true
    has_many :refunds, class_name: 'Square::Refund', dependent: :destroy

  end
end
