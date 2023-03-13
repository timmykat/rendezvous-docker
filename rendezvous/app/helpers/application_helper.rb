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

  def my_registration_path(user)
    id = user.registrations.where("year='#{Time.now.year.to_s}'").pluck(:id).first
    if (!id.blank?)
      "/registrations/#{id.to_s}"
    end
  end

  def sign_in_method(user)
    if user.provider
      user.provider.titlecase
    else
      user.email
    end
  end

  def registration_row_class(registration)
    klass = 'text-center '
    case registration.status
      when 'complete'
        klass += 'alert-success'
      when 'initiated'
        klass += 'alert-warning'
      when 'payment due'
      when 'in review'
        klass += 'alert-danger'
      when 'cancelled'
        klass += 'alert-cancelled'
    end
  end

  def address_of(user)
    address  = '<div class="text-left">'
    address += user.address1 + "<br />\n" if !user.address1.blank?
    address += user.address2 + "<br />\n" if !user.address2.blank?
    address += user.city if !user.city.blank?
    address += ", " + user.state_or_province if !user.state_or_province.blank?
    address += " " + user.postal_code + "<br />\n" if !user.postal_code.blank?
    address += user.country_name + "</div>\n"
    return address.html_safe if address
  end

  def vehicles_list(vehicles)
    if vehicles
      output = "<ul class='list-unstyled'>\n"
      vehicles.each do |vehicle|
        output += " <li>#{vehicle.year_marque_model}</li>\n"
      end
      output += "</ul>\n"
      output.html_safe
    end
  end

  def mailing_address(delimiter = "<br />\n")
    Rails.configuration.rendezvous[:official_contact][:mailing_address_array].join(delimiter).html_safe
  end

  def official_contact
    config = Rails.configuration.rendezvous
    output = '<p><em>Mailing address: </em><br />'
    output +=  mailing_address
    output += '<p><em>Chief officer:</em> ' + Rails.configuration.rendezvous[:official_contact][:chief_officer] + "</p>\n"
    output += '<p><em>Official email:</em> ' + Rails.configuration.rendezvous[:official_contact][:email] + "</p>\n"
    output += '<p><em>Facebook:</em> <a href="' + config[:official_contact][:facebook] + '"><i class="fa fa-facebook-square"></i></a></p>' + "\n"
    output.html_safe
  end

  def marques
    Rails.configuration.rendezvous[:vehicle_marques].map{ |m| [m, m] }
  end

  def models
    Rails.configuration.rendezvous[:vehicle_models].map{ |m| [m, m] }
  end

  def selected_marque(vehicle)
    if marques.include? vehicle.marque
      vehicle.marque
    elsif vehicle.marque.blank?
      'Citroen'
    else
      'Other'
    end
  end

  def other_marque(vehicle)
    if !marques.include? vehicle.marque
      vehicle.marque
    end
  end

  def selected_model(vehicle)
    if models.include? vehicle.model
      vehicle.model
    else
      nil
    end
  end

  def other_model(vehicle)
    if !models.include? vehicle.model
      vehicle.model
    else
      nil
    end
  end

  def month_list
    [
      ['[01]  January', '01'],
      ['[02]  February', '02'],
      ['[03]  March', '03'],
      ['[04]  April', '04'],
      ['[05]  May', '05'],
      ['[06]  June', '06'],
      ['[07]  July', '07'],
      ['[08]  August', '08'],
      ['[09]  September', '09'],
      ['[10]  October', '10'],
      ['[11]  November', '11'],
      ['[12]  December', '12']
    ]
  end

  def year_list
    [*2016..2022]
  end

  def country_list
    Rails.configuration.rendezvous[:countries].map{|code, name| [name, code] }
  end

  def state_province_list
    [
      ['Northeastern US', [
        ['Connecticut', 'CT'],
        ['Maine', 'ME'],
        ['Massachusetts', 'MA'],
        ['New Hampshire', 'NH'],
        ['New Jersey', 'NJ'],
        ['New York', 'NY'],
        ['Pennsylvania', 'PA'],
        ['Vermont', 'VT'],
      ]],
      ['Southeastern Canada', [
        ['Ontario', 'ON'],
        ['Quebec', 'QC'],
        ['New Brunswick', 'NB'],
      ]],
      ['Other US', [
        ['Alabama', 'AL'],
        ['Alaska', 'AK'],
        ['Arizona', 'AZ'],
        ['Arkansas', 'AR'],
        ['California', 'CA'],
        ['Colorado', 'CO'],
        ['Delaware', 'DE'],
        ['District of Columbia', 'DC'],
        ['Florida', 'FL'],
        ['Georgia', 'GA'],
        ['Hawaii', 'HI'],
        ['Idaho', 'ID'],
        ['Illinois', 'IL'],
        ['Indiana', 'IN'],
        ['Iowa', 'IA'],
        ['Kansas', 'KS'],
        ['Kentucky', 'KY'],
        ['Louisiana', 'LA'],
        ['Maryland', 'MD'],
        ['Michigan', 'MI'],
        ['Minnesota', 'MN'],
        ['Mississippi', 'MS'],
        ['Missouri', 'MO'],
        ['Montana', 'MT'],
        ['Nebraska', 'NE'],
        ['Nevada', 'NV'],
        ['New Mexico', 'NM'],
        ['North Carolina', 'NC'],
        ['North Dakota', 'ND'],
        ['Ohio', 'OH'],
        ['Oklahoma', 'OK'],
        ['Oregon', 'OR'],
        ['Rhode Island', 'RI'],
        ['South Carolina', 'SC'],
        ['South Dakota', 'SD'],
        ['Tennessee', 'TN'],
        ['Texas', 'TX'],
        ['Utah', 'UT'],
        ['Virginia', 'VA'],
        ['Virgin Islands', 'VI'],
        ['Washington', 'WA'],
        ['West Virginia', 'WV'],
        ['Wisconsin', 'WI'],
        ['Wyoming', 'WY']
      ]],
      ['Other Canada', [
        ['Alberta', 'AB'],
        ['British Columbia', 'BC'],
        ['Manitoba', 'MB'],
        ['Newfoundland', 'NF'],
        ['Northwest Territories', 'NT'],
        ['Nova Scotia', 'NS'],
        ['Prince Edward Island', 'PE'],
        ['Saskatchewan', 'SK'],
        ['Yukon  ', 'YT'],
      ]]
    ]
  end

end