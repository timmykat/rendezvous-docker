class SquareTransaction < ApplicationRecord
  belongs_to :registration, optional: true
  belongs_to :donation, optional: true
  belongs_to :user
end
