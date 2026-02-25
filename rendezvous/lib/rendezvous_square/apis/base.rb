require 'square'
require 'securerandom'

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
        bearer_auth_credentials: ::Square::BearerAuthCredentials.new(
          access_token: ENV.fetch("#{get_environment}_SQUARE_ACCESS_TOKEN")
        ),
        environment: get_environment.downcase == 'prod' ? 'production' : 'sandbox',
        max_retries: 2
      )
    end
  
    def idempotency_key
      return SecureRandom.uuid
    end

    def iso_3166_alpha2(country)
      codes = {
        "AUT": "AT",
        "BEL": "BE",
        "CAN": "CA",
        "CHE": "CH",
        "DEU": "DE",
        "DNK": "DK",
        "ESP": "ES",
        "FRA": "FR",
        "GBR": "GB",
        "HRV": "HR",
        "IRL": "IE",
        "ITA": "IT",
        "MEX": "MX",
        "NLD": "NL",
        "NOR": "NO",
        "PRT": "PT",
        "SWE": "SE",
        "USA": "US",
      }
      return codes[country]
    end

    RETRY_LIMIT = 2
    SLOW_REQUEST_THRESHOLD = 2.0
    def with_error_handling
      retries = 0
  
      begin
        start_time = Time.now
        result = yield
        duration = Time.now - start_time

        if duration > SLOW_REQUEST_THRESHOLD
          Rails.logger.warn("⚠️  Slow Square API call: #{duration.round(2)}s")
        end
        result

      rescue Faraday::TimeoutError, Net::ReadTimeout, Faraday::ConnectionFailed => e
        Rails.logger.error("Square network error: #{e.class} - #{e.message}")
        if retries < RETRY_LIMIT
          retries += 1
          Rails.logger.warn("Retrying Square request (#{retries}/#{RETRY_LIMIT})...")
          sleep(0.5 * retries)
          retry
        else
          # You can raise a custom error if you want
          raise "Square network request failed after retries: #{e.message}"
        end
      rescue ::Square::APIException => e
        Rails.logger.error("Square API exception details: #{e.response_details}") if e.respond_to?(:response_details)
        raise
      end
    end
  end
end
