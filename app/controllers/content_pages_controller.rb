class ContentPagesController < ApplicationController
  before_action :set_main_page, only: [:show, :edit, :update, :destroy]

  # GET /
  def index
    @pictures = Picture.front_page_set
    @cache_buster = "?cb=#{Time.now.to_i}"
    render :layout => 'main_page'
  end
  
  def history
  end
  
  def vendors
  end
  
  def legal_information
  end
  
  def contact_us
    @name = params[:name]
    @email = params[:email]
    @message = params[:message]

    Mailer.send_to_us(@name, @email, @message).deliver_later
    Mailer.autoresponse(@name, @email, @message).deliver_later
    flash_notice 'Thank you for sending us a message: you should receive a confirmation email shortly.'
    redirect_to :root
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_main_page
      @main_page = MainPage.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def main_page_params
      params[:main_page]
    end
end
