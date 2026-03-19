module RendezvousSquare
  module Checkout
    include Base

    def api
      # Ensure Base.get_square_client returns the main client
      Base.get_square_client.refund
    end

    def post_refund(params)
      begin
        result = api.refund_payment(**create_refund_body(params))
        refund = result.refund

    def create_refund_body(params)
      {
        payment_id: params[:payment_id]
        amount_money: {
          amount: params[:amount],
          currency: "USD"
        },
        reason: params[:reason],
        idempotency_key: Base.idempotency_key
      }
    end
  end
end