class MainPagesController < ApplicationController
  before_action :set_main_page, only: [:show, :edit, :update, :destroy]
  before_action :check_test_param, only: [:index]

  def check_test_param
    session[:test_session] = params[:test] && params[:test].downcase == 'opron'
  end

  # GET /
  def index
    @accommodations = Admin::EventHotel.first
    @events_by_day = Admin::ScheduledEvent.all.each_with_object({}) do |event, hash|
      (hash[event[:day]] ||= []) << event
    end
  end
  
  def faq
    @title = 'FAQ'
    @faqs = Admin:Faq.sort(:order).all
  end
  
  def history
    @title = 'History'
  end
    
  def legal_information
    @title = 'Legal Information'
  end

  def vendors
    @title = 'Vendors'
    @faqs = Admin::Vendor.sort(:order).all
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
