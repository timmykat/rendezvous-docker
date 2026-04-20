class DonationsController < ApplicationController

  before_action :require_admin, { only: %i[index get_registration_donations] }

  def index
  end

  def new
    if current_user&.admin?
      @donation = Donation.new(created_by_admin: true, status: :initialized)
      @donation.build_user
    elsif current_user
      @donation = Donation.new(user: current_user, status: :initialized)
    else
      @donation = Donation.new(status: :initialized)
      @donation.build_user
    end
  end

  def create
    user_attrs = params[:donation][:user_attributes]
    user = User.find_by(id: user_attrs[:id].presence) || begin
      user = User.new(user_attrs.permit(:first_name, :last_name, :email))
      user.generate_password
      user.save
      user
    end

    @donation = Donation.new(donation_params)
    @donation.user = user
    @donation.first_name ||= user.first_name
    @donation.last_name ||= user.last_name

    unless @donation.save
      flash_alert @donation.errors.full_messages.to_sentence
      render :new and return
    end

    @donation.update(status: :created)

    redirect_url = thank_you_url(@donation, type: 'standard')
    customer_id = user.ensure_square_customer_id!

    square_payment_link = ::RendezvousSquare::Apis::Checkout.create_square_payment_link(
      donation: @donation,
      customer_id: customer_id,
      redirect: redirect_url
    )

    redirect_to square_payment_link, allow_other_host: true
  end

  def thank_you
    @donation = Donation.find(params[:id])
    @type = params[:type]
    @donation.status = :complete
    @donation.save

    # transaction_id = params[:transactionId]
    # order_id = params[:orderId]


    # if transaction_id && order_id
    #   create_transaction(order_id, transaction_id)
    # end
    render :thank_you and return
  end

  def create_transaction(order_id, transaction_id)
    transaction = ::Square::Transaction.new
    transaction.user = @donation.user
    transaction.amount = @donation.amount
    transaction.transaction_id = transaction_id
    transaction.order_id = order_id
    transaction.donation_id = @donation.id
    transaction.save
  end

  def get_registration_donations

    existing_records = Donation.where.not(registration_id: nil).all
    existing_records.destroy_all

    Event::Registration.where(donation > 0.0).where(status: :complete).all.each do |r|
      d = Donation.new
      d.amount = r.donation
      d.registration_id = r.id
      d.user_id = r.user.id
      e.email = r.user.email
      d.status = :complete
      d.save
    end
    redirect_to :index
  end

  def destroy
  end

  private

  def user_params
    params.require(:user).permit(
      :id,
      :email,
      :first_name,
      :last_name,
      :city,
      :state_or_province,
      :postal_code,
      :country
    )
  end

  def donation_params
    params.require(:donation).permit(
      :amount,
      :first_name,
      :last_name,
      :status,
      :created_by_admin,
      { user_attributes: [
        :id,
        :email,
        :first_name,
        :last_name,
        :city,
        :state_or_province,
        :postal_code,
        :country
      ] }
    )
  end
end
