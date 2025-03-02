class Admin::Faq < ApplicationRecord
  validates :question, presence: true
end
