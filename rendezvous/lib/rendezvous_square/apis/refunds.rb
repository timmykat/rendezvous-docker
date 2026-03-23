module RendezvousSquare
  module Apis
    module Refunds
      include Apis::Base

      def self.api
        # Note: Added 'self' if you want to call this as a module method
        Apis::Base.get_square_client.refunds
      end

      def self.post_refund(params)
        result = api.refund_payment(body: create_refund_body(params))
        if result.success?
          result.data.refund
        else
          Rails.logger.error "Refund Failed: #{result.errors}"
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

        return Apis::Base.get_all(api, 'list', ** params)
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
