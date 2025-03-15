class Admin::Vendor < ApplicationRecord

  include RailsSortable::Model
  set_sortable :order

  include SortingConcern
  
end
