class UsersController < ApplicationController

  before_action :authenticate_user!, only: [:welcome, :edit, :update]
  before_action :require_admin, only: [:toggle_admin, :synchronize_with_mailchimp]

  def welcome
    @user = User.find(params[:id])
  end

  def show
    @user = User.find(current_user.id)
  end

  def edit
    @user = User.find(params[:id])
    @registration = @user.registrations.current.last
  end

  def update
    @user = User.find(params[:id])
    if !@user.update(user_params)
      flash_alert_now 'We had a problem saving your updated information'
      flash_alert_now  @user.errors.full_messages.to_sentence
      render action: :edit
    else
      action = @user.receive_mailings? ? 'subscribe' : 'unsubscribe'
      response = @user.mailchimp_action(action)
      if response[:status] == :ok
        flash_notice('Your user information and mailing list status were updated.')
      else
        flash_alert('Your user information was updated, but there was a problem updating your mailing list status.')
        flash_alert(response[:message])
      end
      redirect_to user_path(@user)
    end
  end

  def join_mailing_list
    gibbon = Gibbon::Request.new   # Automatically uses   MAILCHIMP_API_KEY environment variable
    gibbon.timeout = 10

    gibbon.lists(Rails.configuration.mailchimp.list_id).members.create(body: {email_address: params[:email], status: "subscribed"})
  end

  def find_by_email
    if User.find_by_email(params[:email])
      status = { exists: true }
    else
      status = { exists: false }
    end
    render json: status
  end

  def toggle_admin
    user = User.find(params[:user_id])
    if params[:admin] == 'admin'
      user.roles << :admin
    else
      user.roles.delete :admin
    end
    user.save!
    render json: true
  end

  def toggle_tester
    user = User.find(params[:user_id])
    if params[:tester] == 'tester'
      user.roles << :tester
    else
      user.roles.delete :tester
    end
    user.save!
    render json: true
  end

  def delete_users
    user_ids = params[:users].split(',')
    users = User.find(user_ids)
    users.each do |u|
      Rails.logger.info "Deleting user #{u.email}"
      u.destroy
    end
    render js: "window.location = '/admin#tabbed-6'"
  end

  def synchronize_with_mailchimp
    response = User.synchronize_with_mailchimp_data
    subscriber_count = response[:user_list].reject { |k,v| v != 'subscribed' }.count
    if response[:status] == :ok
      flash_notice("Synchronization successfull. There are #{subscriber_count} subscribers with accounts.")
    else
      flash_alert(response[:message])
    end
    redirect_to admin_index_path
  end

  private
    def user_params
      params.require(:user).permit(
        [:id, :email, :password, :password_confirmation, :first_name, :last_name, :address1, :address2, :city, :state_or_province, :postal_code, :country, :receive_mailings, :citroenvie,
          {vehicles_attributes:
            [:id, :year, :marque, :model, :other_info, :_destroy]
          }
        ]
      )
    end

end
