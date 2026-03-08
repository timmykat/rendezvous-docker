module AdminHelper
  def sunday_lunch_count
    Event::Registration.current.where(status: 'complete').sum(:sunday_lunch_number)
  end
end