module MainPagesHelper
  DAYS_OF_THE_WEEK = [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday"
  ]

  def can_register?
    (current_user && (current_user.has_any_role? :admin, :tester)) || (Time.now > Rails.configuration.rendezvous[:registration_window][:open] && Time.now <= Rails.configuration.rendezvous[:registration_window][:close])
  end

  def formatted_date(the_date)
    d_of_w = DAYS_OF_THE_WEEK[the_date.wday]
    return "#{d_of_w}, #{the_date.strftime("%B %e")}"
  end
end
