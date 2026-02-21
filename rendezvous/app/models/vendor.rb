# == Schema Information
#
# Table name: vendors
#
#  id                 :bigint           not null, primary key
#  address            :text(65535)
#  email              :string(255)
#  name               :string(255)
#  order              :integer
#  owner_display_name :string(255)
#  phone              :string(255)
#  website            :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  owner_id           :integer
#
# Indexes
#
#  index_vendors_on_order     (order)
#  index_vendors_on_owner_id  (owner_id)
#
# Foreign Keys
#
#  fk_rails_...  (owner_id => users.id)
#
class Vendor < ApplicationRecord
  include MarkdownConcern
  markdown_attributes :address

  belongs_to :owner, class_name: 'User', optional: true

  include RailsSortable::Model
  set_sortable :order

  include SortingConcern

  validates :name, presence: true
end
