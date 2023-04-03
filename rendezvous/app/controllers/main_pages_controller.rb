class MainPagesController < ApplicationController
  before_action :set_main_page, only: [:show, :edit, :update, :destroy]

  # GET /
  def index
    @pictures = Picture.front_page_set
    @cache_buster = "?cb=#{Time.now.to_i}"
    render layout: 'main_page'
  end
  
  def faq
    @title = 'FAQ'
  end
  
  def history
    @title = 'History'
  end
    
  def legal_information
    @title = 'Legal Information'
  end

  def vendors
    @title = 'Vendors'
  end
  
  def method_missing(method_sym, *arguments, &block)
    if Rails.configuration.rendezvous[:info_pages].include? method_sym.to_s
      render method_sym.to_s
    else
      super
    end
  end
  
  def respond_to? (method_sym, include_private = false)
    if Rails.configuration.rendezvous[:info_pages].include? method_sym.to_s
      true
    else
      super
    end
  end
  
  
  def contact_us
    @name = params[:name]
    @email = params[:email]
    @message = params[:message]

    RendezvousMailer.send_to_us(@name, @email, @message).deliver_later
    RendezvousMailer.autoresponse(@name, @email, @message).deliver_later
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
