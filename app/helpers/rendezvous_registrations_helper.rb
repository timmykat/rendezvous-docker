module RendezvousRegistrationsHelper
  def amount_due(registration)
    registration.amount - registration.paid_amount
  end
end
