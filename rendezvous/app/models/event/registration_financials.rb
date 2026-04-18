module Event# app/models/registration_financials.rb
  class RegistrationFinancials
    def initialize(registration)
      @registration = registration
    end

    def total
      registration_fee + donation + lake_cruise_fee
    end

    def balance
      total - (paid_amount + refunded)
    end

    private

    def registration_fee
      @registration.registration_fee.to_d
    end

    def donation
      @registration.donation.to_d
    end

    def lake_cruise_fee
      @registration.lake_cruise_fee.to_d
    end

    def paid_amount
      @registration.paid_amount.to_d
    end

    def refunded
      @registration.refunded.to_d
    end
  end
end
