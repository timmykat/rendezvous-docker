class DonationsController < ApplicationController

  before_action :require_admin, { only: [:index, :get_registration_donations] }

  def index
  end

  def make_a_donation
    @donation = Donation.new
  end

  def create
    @donation = Donation.find(params[:id])

    if !@donation.update(donation_params)
      flash_alert 'There was a problem creating your donation'
      render :make_a_donation
    else
      @donation.status = 'created'
      @donation.save

      customer_id = ::RendezvousSquare::Customer.find_customer(@donation.email)
      if !customer_id
        customer_id = ::RendezvousSquare::Customer.create_customer(user)
      else
        Rails.logger.info("Square customer found: " + customer_id)
      end

      redirect_url = thank_you_url(@donation)
      square_payment_link = ::RendezvousSquare::Checkout.create_square_payment_link(@donation, customer_id, redirect_url)
      redirect_to square_payment_link, allow_other_host: true
    end
  end

  def thank_you
    @donation = Donation.find(params[:id])
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
end
