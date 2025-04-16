class MainPagesController < ApplicationController
  before_action :set_main_page, only: [:show, :edit, :update, :destroy]
  before_action :check_test_param, only: [:index]
  before_action :set_cache_headers
  before_action :authenticate_user!, only: [ :landing_page ]

  def check_test_param
    session[:test_session] = params[:test] && params[:test].downcase == 'opron'
  end

  # GET /
  def index
    @event_hotel = EventHotel.first
    @events_by_day = ScheduledEvent.all.group_by(&:day)
  end
  
  def faq
    @title = 'FAQ'
    @faqs = Admin:Faq.sorted
    fresh_when @faqs
  end
  
  def history
    @title = 'Rendezvous History'
    @content = KeyedContent.find_by_key "page_history"
  end
    
  def legal_information
    @title = 'Legal Information'
    @content = KeyedContent.find_by_key "page_legal"
  end

  def schedule
    @scheduled_events = ScheduledEvent.sorted
  end

  def vendors
    @title = 'Vendors'
    @vendors = Admin::Vendor.sorted
  end

  def volunteering
    @title = 'Volunteering'
    @content = KeyedContent.find_by_key 'page_volunteering'
  end

  def landing_page
    current_user.expire_token
    @registration = current_user.current_registration
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

    RendezvousMailer.send_to_us(@name, @email, @message).deliver
    RendezvousMailer.autoresponse(@name, @email, @message).deliver
    flash_notice 'Thank you for sending us a message: you should receive a confirmation email shortly.'
    redirect_to :root
  end

  def set_cache_headers
    response.headers['Cache-Control'] = 'public, max-age=86400'
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
