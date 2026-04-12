module RendezvousSquare
  module Apis
    module Payments
      include Apis::Base

      STATUSES = %w[APPROVED PENDING COMPLETED FAILED CANCELED].freeze

      def self.list(params)
        params = params.merge(
          location_ids: [Apis::Base.get_location_id],
          begin_time: Apis::Base::CURRENT_YEAR
        )
        Apis::Base.fetch_paginated(:payments, 'list', **params)
      end

      def self.all
        params = {
          location_ids: [Apis::Base.get_location_id],
          begin_time: Apis::Base::ORIGIN_DATE_ISO
        }
        Apis::Base.fetch_paginated(:payments, 'list', **params)
      end
    end
  end
end
