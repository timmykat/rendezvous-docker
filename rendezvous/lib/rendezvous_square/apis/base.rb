require 'square.rb'
require 'securerandom'

include Square

module RendezvousSquare
  module Base

    extend self
  
    def get_environment
      Config::SiteSetting.instance.square_environment || 'SANDBOX'     
    end

    def get_location_id
      ENV.fetch "#{get_environment}_SQUARE_LOCATION_ID"
    end
  
    def get_square_client
      return ::Square::Client.new(
        bearer_auth_credentials: ::BearerAuthCredentials.new(
          access_token: ENV.fetch("#{get_environment}_SQUARE_ACCESS_TOKEN")
        ),
        environment: get_environment.downcase == 'prod' ? 'production' : 'sandbox',
        timeout: 1
      )
    end
  
    def idempotency_key
      return SecureRandom.uuid
    end

    def iso_3166_alpha2(country)
      codes = {
        "USA": "US",
        "CAN": "CA",
        "MEX": "MX",
        "AUT": "AT",
        "BEL": "BE",
        "HRV": "HR",
        "DNK": "DK",
        "FRA": "FR",
        "DEU": "DE",
        "IRL": "IE",
        "ITA": "IT",
        "NLD": "NL",
        "NOR": "NO",
        "PRT": "PT",
        "ESP": "ES",
        "SWE": "SE",
        "CHE": "CH",
        "GBR": "UK"
      }
      return codes[country]
    end
  end
end
