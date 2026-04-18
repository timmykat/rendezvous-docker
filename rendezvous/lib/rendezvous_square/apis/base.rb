require 'square'
require 'securerandom'

module RendezvousSquare
  module Apis
    module Base

      ORIGIN_DATE_ISO = Time.utc(2023, 1, 1).iso8601
      CURRENT_YEAR = Time.utc(Time.new.year, 1, 1).iso8601
      RETRY_LIMIT = 2
      SLOW_REQUEST_THRESHOLD = 2.0

      extend self

      def get_environment
        Config::SiteSetting.instance.square_environment || 'SANDBOX'
      end

      def env_key
        get_environment.downcase.to_sym
      end

      def integerize(currency_amount)
        (currency_amount.to_d * 100).round
      end

      def get_square_client
        base_url = get_environment == 'PROD' ? Square::Environment::PRODUCTION : Square::Environment::SANDBOX
        access_token = ENV.fetch("#{get_environment}_SQUARE_ACCESS_TOKEN")
        return ::Square::Client.new(
          token: access_token,
          base_url: base_url
        )
      end

      CLIENT = get_square_client

      def get_location_id
        ENV.fetch "#{get_environment}_SQUARE_LOCATION_ID"
      end

      def idempotency_key
        return SecureRandom.uuid
      end

      def fetch_paginated(api_type, method, **params)
        all_items = []

        query_params = {
          location_ids: [Apis::Base.get_location_id],
          begin_time: Apis::Base::ORIGIN_DATE_ISO,
          cursor: nil
        }

        query_params = query_params.merge(params) if params.present?

        loop do
          begin
            api = CLIENT.send(api_type.to_s)
            response = api.public_send(method, **query_params)

            response.each { |item| all_items << item }

            cursor = response.respond_to?(:cursor) ? response.cursor : nil
            break unless cursor

            query_params[:cursor] = cursor

          rescue Square::Errors::ClientError => e
            Rails.logger.error(e.message)
            return []

          rescue StandardError => e
            Rails.logger.error(e.message)
            return []
          end
        end

        all_items
      end

      def extract_data(response)
        begin
          if response.respond_to?(:orders)
            return response.orders
          end

          if response.respond_to?(:payments)
            return response.payments
          end

          if response.respond_to?(:refunds)
            return response.refunds
          end

          if response.respond_to?(:customers)
            return response.customers
          end
        rescue StandardError => e
          Rails.logger.error(e.message)
        end
      end

      def with_error_handling
        retries = 0

        begin
          start_time = Time.now
          response = yield
          duration = Time.now - start_time

          if duration > SLOW_REQUEST_THRESHOLD
            Rails.logger.warn("⚠️  Slow Square API call: #{duration.round(2)}s")
          end
          response

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
        rescue ::Square::Errors => e
          Rails.logger.error("Square error details: #{e.response_details}") if e.respond_to?(:response_details)
          raise
        end
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
    end
  end
end
