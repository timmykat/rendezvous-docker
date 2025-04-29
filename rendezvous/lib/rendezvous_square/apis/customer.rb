module RendezvousSquare
  module Customer
    include Base

    extend self

    def api
      client = get_square_client
      return client.customers
    end

    def find_customer(email)
      filter_body = create_email_filter(email)
      result = api.search_customers(body: filter_body)
      customer_id = nil
      if result.success?
        return nil if result.data.nil? || result.data[:customers].nil? || result.data[:customers].empty?
        result.data[:customers].each do |c|
          customer_id = c[:id]
        end
      elsif results.error?
        warn result.errors
        return nil
      end
      return customer_id
    end

    def create_email_filter(email)
      return {
        query: {
          filter: {
            email_address: {
              fuzzy: email
            }
          }
        },
        limit: 1
      }
    end

    def create_customer(user)
      Rails.logger.info("Creating new Square customer: " + user.email)
      body = create_customer_object(user)
      result = api.create_customer(body: body)

      if result.success?
        return result.data[:customer][:id]
      elsif result.error?
        warn result.errors
        return false
      end
    end

    def create_customer_object(user)
      return {
        given_name: user.first_name,
        family_name: user.last_name,
        email_address: user.email,
        address: {
          address_line_1: user.address1,
          address_line_2: user.address2,
          locality: user.city,
          administrative_district_level_1: user.state_or_province,
          postal_code: user.postal_code,
          country: iso_3166_alpha2(user.country)
        }
      }
    end

  end
end
