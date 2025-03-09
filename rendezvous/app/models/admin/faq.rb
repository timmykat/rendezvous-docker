class Admin::Faq < ApplicationRecord
  include MarkdownConcern
  validates :question, presence: true

  markdown_attributes :question, :response
end
