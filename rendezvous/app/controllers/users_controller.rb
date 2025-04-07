class UsersController < ApplicationController

  before_action :authenticate_user!, only: [:welcome, :edit, :update]

  def welcome
    @user = User.find(params[:id])
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
    @event_registration = @user.registrations.current.last
  end

  def update
    @user = User.find(params[:id])
    if !@user.update(user_params)
      flash_alert_now 'We had a problem saving your updated information'
      flash_alert_now  @user.errors.full_messages.to_sentence
      render action: :edit
    else
      if params[:redirect_url]
        redirect_to params[:redirect_url]
      else
        redirect_to user_path(@user)
      end
    end
  end

  def find_by_email
    user = User.find_by_email(params[:email])
    render json: user, only: [
      :first_name, 
      :last_name, 
      :address1, 
      :address2,
      :city, 
      :state_or_province,
      :postal_code,
      :country 
    ]
  end

  def toggle_role
    user = User.find(params[:id])
    role = params[:role].to_sym
    if user.has_role? role
      user.roles.delete role
    else 
      user.roles << role
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

  private
    def user_params
      params.require(:user).permit(
        [:email, :password, :password_confirmation, 
        :first_name, :last_name, :address1, :address2, :city, :state_or_province, :postal_code, :country, 
        :citroenvie,
          {vehicles_attributes:
            [:id, :year, :marque, :model, :other_info, :for_sale, :_destroy]
          }
        ]
      )
    end

end
