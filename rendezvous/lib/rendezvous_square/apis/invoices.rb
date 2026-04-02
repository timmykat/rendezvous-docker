module RendezvousSquare
  module Apis
    module Invoices
      include Apis::Base

      def self.api
        Apis::Base.get_square_client.payments
      end

      def self.create(params = {})
        params.merge(
          {
            location_id: Apis::Base.get_location_id
          }
        )
        Apis::Base.create(api, 'create', **params)
      end
    end
  end
end
