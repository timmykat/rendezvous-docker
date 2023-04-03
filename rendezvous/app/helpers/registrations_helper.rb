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
    
  def donation_list(raw_values)
    list = raw_values.map{ |v| ["$#{v.to_s}", v]  }
    list << ['Other', 'other']
  end
  
  def payment_options
    [['I wish to pay by credit card now', 'credit card'], [' I wish to pay by check', 'check']]
  end
end
