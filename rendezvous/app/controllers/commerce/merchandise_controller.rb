module Commerce
  class MerchandiseController < ApplicationController

    before_action :require_admin
    
    def new
        @merchandise = Merchandise.new
        @merchandise.merchitems << Merchitem.new
    end

    def create
        @merchandise = Merchandise.new(merchandise_params)

        @merchandise = generate_skus(@merchandise)

        # remaining = inventory --- to start
        @merchandise.merchitems.each do |item|
          item.remaining = item.starting_inventory
        end

        if !@merchandise.save
            flash_alert_now @merchandise.errors.full_messages
            redirect_to new_commerce_merchandise_path
        else
            flash_notice 'The merchandise item was successfully created'
            redirect_to commerce_merchandise_index_path
        end
    end

    def show
        @merchandise = Merchandise.find(params[:id])
    end

    def edit
      @merchandise = Merchandise.find(params[:id])
    end

    def update
      @merchandise = Merchandise.find(params[:id])
      if !@merchandise.update(merchandise_params)
        flash_alert_now @merchandise.errors.full_messages
        redirect_to edit_commerce_merchandise_path(@merchandise)
      else
        flash_notice 'The merchandise item was successfully updated'
        redirect_to commerce_merchandise_index_path
      end
    end

    def index
        @merchandise = Merchandise.all
    end

    private
      def generate_skus(merchandise)
        merchandise.merchitems.each do |item|
          item.sku = "#{merchandise.sku}-#{item.size.parameterize }"
        end
        return merchandise
      end

      def merchandise_params
        params.require(:commerce_merchandise).permit(
          :id,
          :sku,
          :untracked_merchandise,
          :sale_price,
          :unit_cost,
          { merchitems_attributes:
            [:id, :sku, :size, :inventory, :remaining, :_destroy]
          }
        )
      end
  end
end
