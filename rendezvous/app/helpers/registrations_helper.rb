module RegistrationsHelper

  def steps
    [ 
      'welcome',
      'create',
      'review',
      'payment',
      'complete',
      'vehicles',
    ]
  end

  def annual_question_responses
    AnnualQuestion::RESPONSES
  end

  def previous_step(current_step)
    index = steps.index(current_step)
    prev_step = (index > 0) ? steps[index - 1] : nil
  end

  def next_step(current_step)
    index = steps.index(current_step)
    next_step = (index - 1 < steps.length) ? steps[index + 1] : nil
  end

  def vendor_fee
    Config::SiteSetting.instance.vendor_fee
  end

  def get_status_icon(status)
    klass = status.gsub(' ', '-')
    case status
    when 'complete'
      klass += ' fa fa-star'
    when 'initiated'
      klass += ' fa fa-step-forward'
    when 'payment due'
      klass += ' fa fa-money'
    when 'in review'
      klass += ' fa fa-spinner'
    when 'cancelled'
      klass += ' fa fa-ban'
    end
  end
    
  def donation_list(raw_values, registration_fees)
    cc_fee = '%.2f' % credit_card_fee(registration_fees)
    list = raw_values.map{ |v| ["$#{v.to_s}", v]  }
    list.unshift ["Credit card fee ($#{ cc_fee})", cc_fee.to_f]
    list << ['Other', 'other']
  end

  def credit_card_fee(amount)
    0.10 + 0.026 * amount   # For Square
  end
  
  def payment_options
    [[' Credit Card', 'credit card'], [' Cash or Check', 'cash or check']]
  end

  def attended_rendezvous_years(user)
    reg = user.registrations.pluck(:year).sort.join(',')
    reg.blank? ? '(none)' : reg
  end

  def existing_event_registration_path
    edit_event_registration_path(current_registration)
  end

  def vehicle_at_rendezvous(registration, vehicle)
    bringing = false
    registration.vehicles.each do |v|
      if v == vehicle
        return true
      end
    end
    return false
  end
end
