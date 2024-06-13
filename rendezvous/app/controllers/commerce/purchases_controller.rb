module Commerce
  class PurchasesController < ApplicationController

    before_action :require_admin

    def new
        @purchase = Purchase.new
        @purchase.cart_items.build
        @available_items = get_available_items
        @cart_item = CartItem.new
    end

    def create
        @purchase = Purchase.new(purchase_params)
        order_id = Purchase.last.blank? ? 1000 : Purchase.last.id + 1

        if @purchase.paid_method == 'credit card'
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
        else
            if @purchase.cash_check_paid != @purchase.amount
                flash_alert "The paid amount and the charge do not match"
                redirect_to edit_commerce_purchase_path(@purchase)
                return
            end
        end

        if !@purchase.save
            flash_alert_now @purchase.errors.full_messages
            redirect_to new_commerce_purchase_path, alert: flash_alert
        else
            update_inventory(@purchase)
            flash_notice 'The purchase was successfully created'
            redirect_to commerce_purchase_path(@purchase)
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
      def update_inventory(purchase)
        purchase.cart_items.each do |item|
          merchitem = Merchitem.find(item.merchitem_id)
          merchitem.remaining -= item.number
          merchitem.remaining = [merchitem.remaining, 0].max
          merchitem.save!
        end
      end

      def get_available_items
        items = Merchitem.all
        options = []
        items.each do |item|
          sku = item.merchandise.sku
          price = "$#{item.merchandise.sale_price.to_i}"
          options << ["#{price} | #{sku} (#{item.size}) - #{item.remaining} left", item.id ]
        end
        return options
      end

      def purchase_params
        params.require(:purchase).permit(
          :id,
          :untracked_merchandise,
          :category,
          :amount,
          :total,
          :email,
          :first_name,
          :last_name,
          :postal_code,
          :country,
          :cc_transaction_id,
          :cc_transaction_amount,
          :cash_amount,
          { cart_items_attributes: 
              [:id, :merchitem_id, :number, :_destroy]
        })
      end
  end
end
