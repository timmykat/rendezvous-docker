class UsersController < ApplicationController

  before_action :authenticate_user!, only: [:welcome, :edit, :update, :new_by_admin, :create_by_admin]
  before_action :require_admin, only: [:new_by_admin, :create_by_admin, :index]
  before_action :select_layout

  def new_user_by_admin
    @user = User.new
    @user.is_admin_created = true
    @user.vehicles.build
    @available_qr_codes = QrCode.unassigned
  end

  def create_user_by_admin
    @user = User.new(user_params)
    @user.generate_password
    if @user.email.blank?
      @user.generate_email_address
    end
    Rails.logger.debug @user
    if !@user.save
      render :new_user_by_admin, alert: "Unable to create user: #{@user.errors.full_messages}"
    else
      flash_notice "User created with email #{@user.email}"
      redirect_to @user
    end
  end

  def index
    @users = User.all
  end

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

  def toggle_whitelist
    user = User.find(params[:id])
    user.recaptcha_whitelisted = !user.recaptcha_whitelisted
    user.save!
    Rails.logger.debug "Recaptcha | #{user.email} | #{user.recaptcha_whitelisted ? 'whitelisted' : 'not whitelisted'}"
    render json: true
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

  def autocomplete
    user = User.find_by_email(params[:email])
    if (params[:reg_page])
      if user.present? && user.current_registration
        respond_to do |format|
          format.json do 
            render json: {
              existing_registration: edit_event_registration_path(user.current_registration)
            }
          end
        end
        return
      end
    end
    respond_to do |format|
      format.json do 
        if !user
          render json: { status: 'not found' }
        else
          render json: user.as_json(only: [
            :id,
            :first_name,
            :last_name,
            :city,
            :state_or_province,
            :postal_code,
            :country
          ])
        end
      end
    end
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
        :first_name, :last_name, :address1, :address2, :city, :state_or_province, :postal_code, :country, :is_admin_created, 
        :citroenvie,
          {vehicles_attributes:
            [:id, :year, :marque, :model, :other_info, :for_sale, :_destroy,
            qr_code_attributes: [:id, :code, :_destroy]]
          }
        ]
      )
    end

    def select_layout
      ['index', 'new_by_admin', 'create_by_admin'].include?(action_name) ? "admin_layout" : "application"
    end

end
