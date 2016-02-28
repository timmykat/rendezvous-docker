module ApplicationHelper
  def logged_in_user(user)
    if user.first_name
      display = "Welcome #{user.first_name}"
    elsif user.last_name
      display = "You are signed in as #{user.last_name}"
    elsif user.provider
      display = "You are signed in via #{user.provider.titlecase}"
    else
      display = "You are signed in as #{user.email}"
    end
  end
  
  def full_name(user)
    "#{user.first_name} #{user.last_name}"
  end
  
  def last_name_first(user)
    "#{user.last_name}, #{user.first_name}"
  end

  def vehicles_list(vehicles)
    output = "<ul class='list-unstyled'>\n"
    vehicles.each do |vehicle|
      output += " <li>#{vehicle.full_spec}</li>\n"
    end
    output += "</ul>\n"
    output.html_safe
  end
  
  def mailing_address(delimiter = '<br />')
    RendezvousRegistration.mailing_address_array.join(delimiter).html_safe
  end
end
