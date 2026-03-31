# app/services/registrations/mark_as_paid.rb
module Registrations
  class MarkAsPaid
    def initialize(registration, amount)
      @registration = registration
      @amount = amount
    end

    def call
      return false unless fully_paid?

      @registration.update!(status: 'complete - confirmed')
    end

    private

    def fully_paid?
      @registration.paid_amount.to_d == @amount.to_d
    end
  end
end
