module RendezvousRegistrationsHelper
  def amount_due(registration)
    if registration.paid_amount.blank?
     registration.total
    else
      registration.total - registration.paid_amount
    end
  end
  
  def donation_list(raw_values)
    list = raw_values.map{ |v| ["$#{v.to_s}", v]  }
    list << ['Other', 'other']
  end
  
  def payment_options
    [['I wish to pay by credit card now', 'credit card'], [' I wish to pay by check', 'check']]
  end
end
