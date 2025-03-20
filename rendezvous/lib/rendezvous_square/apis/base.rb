require 'square.rb'
require 'securerandom'

include Square

module RendezvousSquare
  module Base

    extend self
  
    SQUARE_ENV = :sandbox
    SQUARE_CONFIG = Rails.configuration.rendezvous[:payment_credentials][SQUARE_ENV]
    SQUARE_APPLICATION_ID = SQUARE_CONFIG[:application_id]
    SQUARE_LOCATION_ID = SQUARE_CONFIG[:location_id]
  
    def get_payment_environment
      if Rails.env.production?
        prefix = "PRODUCTION"
      else
        prefix = "SANDBOX"
      end
      return prefix     
    end
  
    def get_square_client
      return ::Square::Client.new(
        bearer_auth_credentials: ::BearerAuthCredentials.new(
          access_token: ENV.fetch(get_payment_environment + '_SQUARE_ACCESS_TOKEN')
        ),
        environment: get_payment_environment.downcase,
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
