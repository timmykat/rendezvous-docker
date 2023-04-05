module MainPagesHelper

  config = Rails.configuration.rendezvous
  
  DAYS_OF_THE_WEEK = [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday"
  ]

  SHORT_FORMAT = "%B %-d"
  FULL_FORMAT = "%A, %B %-d"
  START_DATE = Date.parse(config[:dates][:day_one])
  END_DATE = START_DATE + (config[:dates][:duration] - 1)

  def event_year
    return START_DATE.year
  end

  def event_dates
    output = START_DATE.strftime(SHORT_FORMAT) + "&ndash;" +  END_DATE.strftime(SHORT_FORMAT) + ", " + START_DATE.year.to_s

    mo = output.match(/^[a-zA-Z]+/)
 
    nth = 2
    i = 0
    output = output.gsub(/#{mo} /) do |month|
      i += 1
      if i == nth
        ""
      else
        month
      end
    end
    return output.html_safe
  end

  def relative_date(i)
    return (START_DATE + i).strftime(FULL_FORMAT)
  end

  def tbd_message
    return "Stay tuned"
  end

  def can_register?
    (current_user && (current_user.has_any_role? :admin, :tester)) || (Time.now > Rails.configuration.rendezvous[:registration_window][:open] && Time.now <= Rails.configuration.rendezvous[:registration_window][:close])
    false
  end

  def formatted_date(the_date)
    d_of_w = DAYS_OF_THE_WEEK[the_date.wday]
    return "#{d_of_w}, #{the_date.strftime("%B %e")}"
  end
end
