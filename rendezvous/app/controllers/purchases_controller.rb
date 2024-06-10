class PurchasesController < ApplicationController
    def new
        @purchase = Purchase.new
    end

    def create
        @purchase = Purchase.new(purchase_params)
        order_id = Purchase.last.blank? ? 1000 : Purchase.last.id + 1001
        braintree_transaction_params = {
            order_id: order_id,
            amount: @purchase.amount,
            payment_method_nonce: params[:payment_method_nonce],
            customer: {
              first_name: @purchase.first_name,
              last_name: @purchase.last_name,
              email: @purchase.email,
            },
            billing: {
              first_name: @purchase.first_name,
              last_name: @purchase.last_name,
              postal_code: @purchase.postal_code,
              country_code_alpha3: @purchase.country
            },
            options: {
              submit_for_settlement: true
            },
          }

        # Handle the Braintree transaction
        gateway = Braintree::Gateway.new(
          environment: Braintree::Configuration.environment,
          merchant_id: Braintree::Configuration.merchant_id,
          public_key: Braintree::Configuration.public_key,
          private_key: Braintree::Configuration.private_key,
        )

        result = gateway.transaction.sale(braintree_transaction_params)

        if result.success?
            @purchase.cc_transaction_id = result.transaction.id
            @purchase.cc_transaction_amount = @purchase.amount
        end

        if !@purchase.save
            flash_alert_now @purchase.errors.full_messages
            redirect_to new_purchase_path, alert: flash_alert
        else
            flash_notice 'The purchase was successfully created'
            redirect_to purchase_path(@purchase)
        end
    end

    def show
        @purchase = Purchase.find(params[:id])
    end

    def index
        @year = params[:year].blank? ? Time.now.year : params[:year]
        @purchases = Purchase.where('extract(year from created_at) = ?', @year)
    end

    private
        def purchase_params
            params.require(:purchase).permit(
                :id,
                :description,
                :category,
                :amount,
                :email,
                :first_name,
                :last_name,
                :postal_code,
                :country,
                :cc_transaction_id,
                :cc_transaction_amount,
                :cash_amount
            )
        end
end
