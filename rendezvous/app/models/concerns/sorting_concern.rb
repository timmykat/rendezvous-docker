module SortingConcern
  extend  ActiveSupport::Concern

  module ClassMethods
    def sorted
      order(order: :asc)
    end
  end
end

