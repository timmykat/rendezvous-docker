module StripWhitespace
  extend ActiveSupport::Concern

  included do
    before_validation :strip_whitespace
  end

  def strip_whitespace
    attributes.each do |attr, value|
      self[attr] = value.strip if value.respond_to?(:strip)
    end
  end
end