module AdminCreatable
  extend ActiveSupport::Concern

  included do
    scope :created_by_admin, -> { where(created_by_admin: true) }
    scope :not_created_by_admin, -> { where(created_by_admin: [false, nil]) }
  end

  def created_by_admin?
    created_by_admin == true
  end
end