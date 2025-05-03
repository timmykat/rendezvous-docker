class SquareTransaction < ApplicationRecord
  belongs_to :registration, class_name: 'Event::Registration', optional: true
  belongs_to :donation, optional: true
  belongs_to :user
end
