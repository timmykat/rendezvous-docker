module RegistrationsHelper

  SHORT_FORMAT = "%B %-d"
  FULL_FORMAT = "%A, %B %-d"
  DAY_ONLY_FORMAT = "%A"

  def annual_question_responses
    AnnualQuestion::RESPONSES
  end

  def button_state(path, state = 'info')
    if current_page?(path)
      'disabled btn btn-sm btn-success'
    else
      "btn btn-sm btn-#{state}"
    end
  end

  def registration_status_classes(status)
    status = status&.to_sym
    case status
    when :complete
      'bg-success'
    when :in_progress
      'bg-warning text-dark'
    when :cancelled
      'bg-danger'
    else
      'bg-secondary'
    end
  end

  # Square helpers
  def square_env
    ::RendezvousSquare::Apis::Base.get_environment
  end

  def square_app_id
    ENV.fetch "#{square_env}_SQUARE_APP_ID"
  end

  def square_sdk_url
    ENV.fetch "#{square_env}_SQUARE_SDK_URL"
  end

  def square_location_id
    ENV.fetch "#{square_env}_SQUARE_LOCATION_ID"
  end

  def get_status_icon(status)
    klass = status.gsub(' ', '-')
    case status
    when :complete
      klass += ' fa fa-star'
    when :in_progress
      klass += ' fa fa-step-forward'
    when :cancelled
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

  def modify_button_label(reg)
    reg.complete? ? 'Create Modification' : 'Save'
  end

  def payment_status_option_tags
    option_list = ''
    Event::Registration::PAYMENT_STATUSES.each do |s|
      option_list << "<option value=#{s}>#{s.humanize}</option>\n"
    end
    option_list.html_safe
  end

  def payment_status_line_item(reg)
    case
    when reg.paid?
      { label: '', info: 'Paid, thank you!'}
    when reg.outstanding_balance?
      { label: 'Outstanding balance:', info: number_to_currency(reg.balance) }
    when reg.payment_due?
      { label: 'Payment due:', info: number_to_currency(reg.balance) }
    when reg.refund_owed?
      { label: 'Refund owed:', info: "<span style='color: #cc0000;'>#{number_to_currency(reg.balance)}</span>".html_safe }
    when reg.refunded?
      { label: 'Refund:', info: "<span style='color: #660000;'>#{number_to_currency(reg.balance)}</span>".html_safe }
    end
  end


  def user_payment_options
    Event::Registration.paid_methods.except('invoice').map { |k, _| [k.humanize, k] }
  end

  def donation_options
    Rails.configuration.registration[:suggested_donations]
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
