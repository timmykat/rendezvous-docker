module RegistrationsHelper

  SHORT_FORMAT = "%B %-d"
  FULL_FORMAT = "%A, %B %-d"
  DAY_ONLY_FORMAT = "%A"

  def annual_question_responses
    AnnualQuestion::RESPONSES
  end

  def statuses
    Event::Registration::STATUSES
  end

  def registration_status_classes(status)
    case status
    when 'complete'
      'bg-success'
    when 'in progress', 'payment due'
      'bg-warning text-dark'
    when 'cancelled'
      'bg-danger'
    else
      'bg-secondary'
    end
  end

  def payment_due?(balance)
    balance.positive?
  end

  def refund_owed?(balance)
    balance.negative?
  end

  def get_status_icon(status)
    klass = status.gsub(' ', '-')
    case status
    when 'complete'
      klass += ' fa fa-star'
    when 'in progress'
      klass += ' fa fa-step-forward'
    when 'payment due'
      klass += ' fa fa-money'
    when 'cancelled'
      klass += ' fa fa-ban'
    end
  end

  def lake_cruise_close_date
    Rails.configuration.registration[:lake_cruise_close_date].to_time.strftime(SHORT_FORMAT)
  end

  def donation_list(raw_values, registration_fees)
    list = raw_values.map { |v| ["$#{v.to_s}", v] }
    unless registration_fees.nil?
      cc_fee = '%.2f' % credit_card_fee(registration_fees)
      list.unshift ["Credit card fee ($#{ cc_fee})", cc_fee.to_d]
    end
    list << ['Other', 'other']
  end

  def credit_card_fee(amount)
    0.10 + 0.026 * amount # For Square
  end

  def payment_options
    # [[' Credit Card (on line)', 'credit card'], [' Cash or Check', 'cash or check'], [' Square (on site)', 'square on site']]
    [[' Credit card (Square)', 'credit card'], [' Cash or Check', 'cash or check']]
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
