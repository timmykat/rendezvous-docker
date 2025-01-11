require 'json'
require 'square'

module Commerce
  class PurchasesController < ApplicationController



    before_action :require_admin

    def new
        @purchase = Purchase.new
        @purchase.cart_items.build
        if (params[:silent_auction])
          @purchase.untracked_merchandise = "Silent auction purchase"
          @purchase.category = 'silent auction'
          @silent_auction = true
        else
          @purchase.category = 'merch'
          @available_items = get_available_items
        end
        @item_prices = Hash.new
        Merchandise.all.each do |m|
          m.merchitems.each do |item|
            @item_prices[item.id] = m.sale_price
          end
        end
        @item_prices = @item_prices.to_json
    end

    def create
        @purchase = Purchase.new(purchase_params)
        order_id = Purchase.last.blank? ? 1000 : Purchase.last.id + 1

        if @purchase.paid_method == 'credit card'


            if result.success?
                @purchase.cc_transaction_id = result.transaction.id
                @purchase.cc_transaction_amount = @purchase.total
            end
        else
            if @purchase.cash_check_paid != @purchase.total
                Rails.logger.info "Paid: #{@purchase.cash_check_paid.to_s} Total: #{@purchase.total}"
                flash_alert_now "The paid amount and the charge do not match"
                redirect_to new_commerce_purchase_path
                return
            end
        end

        Rails.logger.info 'INSPECTION BEFORE SAVE'
        Rails.logger.info @purchase.inspect

        if !@purchase.save
            flash_alert_now 'There was a problem saving the purchase'
            Rails.logger.info @purchase.errors.full_messages
            redirect_to new_commerce_purchase_path
        else
            update_inventory(@purchase)
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
          options << ["-- #{item.size} -- | #{price} | #{sku} - #{item.remaining} left", item.id ]
        end
        return options
      end

      def purchase_params
        params.require(:commerce_purchase).permit(
          :id,
          :untracked_merchandise,
          :category,
          :generic_amount,
          :total,
          :email,
          :first_name,
          :last_name,
          :postal_code,
          :country,
          :paid_method,
          :cc_transaction_id,
          :cc_transaction_amount,
          :cash_check_paid,
          { cart_items_attributes: 
              [:id, :merchitem_id, :number, :_destroy]
        })
      end
  end
end
