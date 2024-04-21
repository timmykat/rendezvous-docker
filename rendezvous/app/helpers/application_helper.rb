module ApplicationHelper

  RECAPTCHA_SITE_KEY = Rails.configuration.rendezvous[:captcha][:site_key]

  def include_recaptcha_js
    raw %Q{
      <script src="https://www.google.com/recaptcha/api.js?render=#{RECAPTCHA_SITE_KEY}"></script>
    }
  end

  def recaptcha_execute(action)
    id = "recaptcha_token_#{SecureRandom.hex(10)}"

    raw %Q{
      <input name="recaptcha_token" type="hidden" id="#{id}"/>
      <script>
        grecaptcha.ready(function() {
          grecaptcha.execute('#{RECAPTCHA_SITE_KEY}', {action: '#{action}'}).then(function(token) {
            document.getElementById("#{id}").value = token;
          });
        });
      </script>
    }
  end

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

  def user_is_admin?
    current_user && (current_user != @user)
  end

  def in_registration_window?
    Time.now > Rails.configuration.rendezvous[:registration_window][:open] && Time.now <= Rails.configuration.rendezvous[:registration_window][:close]
  end

  def is_tester?
    current_user && (current_user.has_any_role? :admin, :tester)
  end

  def registration_live?
    in_registration_window? || session[:test_session]
  end

  def static_file(file_path)
    "/files/#{file_path}"
  end

  def static_file_url(file_path)
    "#{request.protocol}://#{request.domain}:#{request.port}#{static_file(file_path)}"
  end

  def current_registration
    current_user  && current_user.registrations.where("year='#{Time.now.year.to_s}'").first
  end

  def sign_in_method(user)
    if user.provider
      user.provider.titlecase
    else
      user.email
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

  def les_chauffeurs(separator = ", ")
    return Rails.configuration.rendezvous[:chauffeurs].join(separator)
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
    [*2016..2024]
  end

  def country_list
    Rails.configuration.rendezvous[:countries].map{|code, name| [name, code] }
  end

  def state_province_list
    [
      ['Northeastern US', [
        ['Connecticut', 'CT'],
        ['Delaware', 'DE'],
        ['District of Columbia', 'DC'],
        ['Maine', 'ME'],
        ['Maryland', 'MD'],
        ['Massachusetts', 'MA'],
        ['New Hampshire', 'NH'],
        ['New Jersey', 'NJ'],
        ['New York', 'NY'],
        ['Pennsylvania', 'PA'],
        ['Rhode Island', 'RI'],
        ['Vermont', 'VT'],
        ['Virginia', 'VA'],
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
        ['South Carolina', 'SC'],
        ['South Dakota', 'SD'],
        ['Tennessee', 'TN'],
        ['Texas', 'TX'],
        ['Utah', 'UT'],
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
