# == Schema Information
#
# Table name: faqs
#
#  id         :bigint           not null, primary key
#  display    :boolean          default(TRUE)
#  order      :integer
#  question   :text(65535)
#  response   :text(65535)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_faqs_on_display  (display)
#  index_faqs_on_order    (order)
#
class Faq < ApplicationRecord

  include MarkdownConcern
  markdown_attributes :question, :response

  include RailsSortable::Model
  set_sortable :order

  include SortingConcern

  validates :question, presence: true
end
