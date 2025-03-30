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
  DAY_ONLY_FORMAT = "%A"
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

  def relative_date(i, format = FULL_FORMAT)
    return (START_DATE + i).strftime(format)
  end

  def tbd_message
    return "Stay tuned"
  end

  def formatted_date(the_date)
    d_of_w = DAYS_OF_THE_WEEK[the_date.wday]
    return "#{d_of_w}, #{the_date.strftime("%B %e")}"
  end
end
