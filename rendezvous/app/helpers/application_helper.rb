require_dependency Rails.root.join('lib', 'vehicles', 'vehicle_taxonomy')

module ApplicationHelper
  extend VehicleTaxonomy

  RECAPTCHA_SITE_KEY = Rails.configuration.recaptcha[:site_key]

  # include this as part of the forms where you want them, just before submit
  def recaptcha_script(action)
    id = "recaptcha_token_#{SecureRandom.hex(10)}"
    recaptcha_js =<<~EOF
        <input name="recaptcha_token" type="hidden" id="#{id}"/>
        <script src="https://www.google.com/recaptcha/api.js?render=#{RECAPTCHA_SITE_KEY}"></script>
        <script>
          grecaptcha.ready(() => {
            console.log("Getting recaptcha token")
            grecaptcha.execute("#{RECAPTCHA_SITE_KEY}", {action: "#{action}"})
            .then(token => {
              console.log("Recaptcha token: ", token)
              document.getElementById("#{id}").value = token;
            });
          });
        </script>
    EOF
    recaptcha_js.html_safe
  end

  def get_active_users
    if current_user && current_user.admin?
      n = User.where('last_active > ?', 10.minutes.ago).count - 1
      if n == 0
       "There are no other active users."
      elsif n == 1
        "There is 1 active user."
      else
        "There are #{n} active users."
      end
    end
  end

  def random_id
    return SecureRandom.hex(5)
  end

  def icon(icon, size = "32")
    bootstrap_icon(bootstrap_icon_map[icon], size)
  end

  def bootstrap_icon_map
    {
      add_person: "person-plus-fill",
      address: "geo-alt",
      back: "chevron-double-left",
      bank: "bank",
      car: "car-front-fill",
      close: "x-circle",
      collapse: "chevron-compact-down",
      email: "envelope-at",
      expand: "chevron-compact-up",
      left_arrow: "arrow-left-circle-fill",
      list: "list",
      minus: "dash-square-fill",
      mouse: "mouse-2-fill",
      pdf: "file-earmark-pdf-fill",
      person_f: "person-standing-dress",
      person_m: "person-standing",
      phone: "telephone-fill",
      plus: "plus-square-fill",
      registered: "check-square-fill",
      remove_person: "person-dash-fill",
      right_arrow: "arrow-right-circle-fill",
      speaker: "megaphone-fill",
      spreadsheet: "file-spreadsheet",
      table: "table",
      vendor: "person-raised-hand"
    }
  end

  def bootstrap_icon(icon, size)
    href = image_url("bootstrap-icons/bootstrap-icons.svg")
    tag = <<LITERAL
<svg class="bi" width="#{size}" height="#{size}" fill="currentColor">
    <use href="#{href}##{icon}"></use>
</svg>
LITERAL
    tag.html_safe
  end

  def controller_classes
    classes = "c_#{controller_path.gsub('/', '_')}"
    if controller_path.match(/admin/)
      classes += " admin-page"
    end
    classes
  end

  def event_fee
    Config::SiteSetting.instance.registration_fee
  end

  def refund_date
    Config::SiteSetting.instance.refund_date || Time.now
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

  def voting_on?
    Config::SiteSetting.instance.voting_on
  end

  def user_is_admin?
    current_user && (current_user != @user)
  end

  def before_cutoff_date?
    Time.now <= Config::SiteSetting.instance.registration_close_date
  end

  def after_rendezvous?
    Time.now > Rails.configuration.rendezvous[:registration_window][:after_rendezvous]
  end

  def user_can_test
    current_user && (current_user.has_any_role? :admin, :tester)
  end

  def test_logic(text, boolean)
    "#{text}:  #{boolean ? "PASS" : "FAIL"}"
  end

  def registration_is_open
    (Config::SiteSetting.instance.registration_is_open && before_cutoff_date?)
  end

  def static_file(file_path)
    "/files/#{file_path}"
  end

  def static_file_url(file_path)
    "#{request.protocol}://#{request.domain}:#{request.port}#{static_file(file_path)}"
  end

  def current_registration
    current_user  && current_user.registrations.where("year='#{Date.current.year.to_s}'").first
  end

  def registration_complete
    current_registration && (current_registration.status == 'complete')
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

  def address_of_plain(user)
    address_arr = []
    if !user.address1.blank?
      address_arr << user.address1
    end
    if !user.address2.blank?
      address_arr << user.address2.blank?
    end
    locale = user.city
    if !user.state_or_province.blank?
      locale += ", " + user.state_or_province
    end
    if !user.postal_code.blank?
      locale += " " + user.postal_code
    end
    address_arr << locale
    if !user.country_name.blank?
      address_arr << user.country_name
    end

    return address_arr.join("\n")
  end

  def les_chauffeurs(output = "html")
    if output == "html"
      value = "<ul class='list-unstyled'>\n"
      Rails.configuration.rendezvous[:chauffeurs].each do |c|
        value += "  <li>#{c}</li>"
      end
    else
      value = Rails.configuration.rendezvous[:chauffeurs].join(', ')
    end
    return value.html_safe
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
    output.html_safe
  end

  def marques
    VehicleTaxonomy.get_marques
  end

  def citroen_models
    VehicleTaxonomy.get_citroen_models
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
    if citroen_models.include? vehicle.model
      vehicle.model
    else
      nil
    end
  end

  def other_model(vehicle)
    if !citroen_models.include? vehicle.model
      vehicle.model
    else
      nil
    end
  end

  def vehicles_for_sale
    Vehicle.joins(:registrations)
      .merge(Event::Registration.current)
      .where(for_sale: true)
      .distinct.count
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
    [*2016..Date.current.year]
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
