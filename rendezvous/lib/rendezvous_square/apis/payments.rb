module RendezvousSquare
  module Apis
    module Payments
      include Apis::Base

      STATUSES = %w(APPROVED PENDING COMPLETED FAILED CANCELED)

      def self.api
        Apis::Base.get_square_client.payments
      end

      def self.all
        params = {
          location_ids: [Apis::Base.get_location_id],
          begin_time: Apis::Base::ORIGIN_DATE_ISO
        }
        return Apis::Base.get_all(api, 'list', **params)
      end
    end
  end
end

