module RendezvousSquare
  module Apis
    module Refunds
      include Apis::Base

      STATUSES = %w(PENDING COMPLETED FAILED REJECTED)

      def self.post_refund(params)
        response = Base::CLIENT.refunds.refund_payment(body: create_refund_body(params))
        if response.success?
          response.data.refund
        else
          Rails.logger.error "Refund Failed: #{response.errors}"
          nil
        end
      end

      def self.all
        refunds_list = []
        # Square API usually expects RFC 3339 strings for times
        params = {
          location_ids: [Apis::Base.get_location_id],
          begin_time: Apis::Base::ORIGIN_DATE_ISO
        }

        return Apis::Base.fetch_paginated(:refunds, 'list', ** params)
      end

      private

      def self.create_refund_body(params)
        {
          idempotency_key: SecureRandom.uuid,
          payment_id: params[:payment_id],
          amount_money: {
            amount: params[:amount],
            currency: "USD"
          },
          reason: params[:reason]
        }
      end
    end
  end
end
