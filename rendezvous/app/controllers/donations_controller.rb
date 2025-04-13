class DonationsController < ApplicationController

  before_action :require_admin, { only: [:index, :get_registration_donations] }

  def index
  end

  def new
    @donation = Donation.new
  end

  def create
    @donation = Donation.new(donation_params)

    user = User.find(params[:user][:id])

    if user.nil?
      user = User.create(params[:user])
    end
    @donation.user = user

    if !@donation.save
      flash_alert 'There was a problem creating your donation'
      render :new
      return
    end

    @donation.status = 'created'

    # Look for associated user
    user = User.find_by_email(@donation.email)
    if user
      @donation.user = user
    end

    @donation.save

    customer_id = ::RendezvousSquare::Customer.find_customer(@donation.email)
    if !customer_id
      customer_id = ::RendezvousSquare::Customer.create_customer(user)
    else
      Rails.logger.info("Square customer found: " + customer_id)
    end

    if user.vendor
      redirect_url = thank_you_url(@donation, type: 'vendor')
    else
      redirect_url = thank_you_url(@donation, type: 'standard')
    end

    square_payment_link = ::RendezvousSquare::Checkout.create_square_payment_link(@donation, customer_id, redirect_url)
    redirect_to square_payment_link, allow_other_host: true

  end

  def thank_you
    @donation = Donation.find(params[:id])
    @type = params[:type]
    @donation.status = 'complete'
    @donation.save
  end

  def get_registration_donations

    existing_records = Donation.where.not(registration_id: nil).all
    existing_records.destroy_all

    Event::Registration.where(donation > 0.0).where(status: 'complete').all.each do |r|
      d = Donation.new
      d.amount = r.donation
      d.registration_id = r.id
      d.user_id = r.user.id
      e.email = r.user.email
      d.status = 'complete'
      d.save
    end
    redirect_to :index
  end

  def destroy
  end

  private 
    def donation_params
      params.require(:donation).permit(
        :amount,
        :email,
        { user_attributes: [
          :id, :email, :first_name, :last_name, :city, :state_or_province, :postal_code, :country
        ]}
      )
    end
end
