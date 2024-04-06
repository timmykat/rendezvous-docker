module RegistrationsHelper

  STEP_ARRAY = [ 'welcome', 'sign', 'register', 'review', 'payment', 'vehicles' ]
  
  def registration_progress_indicator(current_step, step, registration = nil)  
    if step == current_step
      klass = 'active'
    elsif STEP_ARRAY.index(step) < STEP_ARRAY.index(current_step)
      klass = 'complete'
    else
      klass = 'to_do'
    end
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
    cc_fee = '%.2f' % braintree_fee(registration_fees)
    list = raw_values.map{ |v| ["$#{v.to_s}", v]  }
    list.unshift ["Credit card fee ($#{ cc_fee})", cc_fee.to_f]
    list << ['Other', 'other']
  end

  def braintree_fee(amount)
    0.49 + 0.0259 * amount
  end
  
  def payment_options
    [['I wish to pay by credit card now', 'credit card'], [' I wish to pay by check', 'check']]
  end

  def attended_rendezvous_years(user)
    reg = user.registrations.pluck(:year).sort.join(',')
    reg.blank? ? '(none)' : reg
  end

  def existing_event_registration_path
    edit_event_registration_path(current_registration)
  end

end
