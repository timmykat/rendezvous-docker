class UsersController < ApplicationController

  before_action :authenticate_user!, only: [:welcome, :edit, :edit_user_vehicles, :update, :new_by_admin, :create_by_admin]
  before_action :require_admin, only: [:new_by_admin, :create_by_admin, :index]
  layout :select_layout

  def select_layout
    ['index', 'new_by_admin', 'create_by_admin'].include?(action_name) ? "admin_layout" : "application"
  end

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
    if (params[:registered])
      @users = User.joins(:registrations).where(registrations: { year: Date.current.year}).all
    else
      @users = User.all
    end
  end

  def welcome
    @user = User.find(params[:id])
  end

  def show
    @user = User.find(params[:id])
    @current_registration = @user.registrations.current.first
  end

  def edit
    @user = User.find(params[:id])
    @event_registration = @user.registrations.current.last
    @available_qr_codes = QrCode.unassigned
  end

  def edit_user_vehicles
    @user = User.find(params[:id])
    @after_complete = params[:after_complete]
  end

  def update
    @user = User.find(params[:id])
    
    # 1. Let Rails handle the standard attributes (including deletion of vehicles)
    if @user.update(user_params)
      
      # 2. Only loop to handle the custom QR code logic
      user_params[:vehicles_attributes]&.each do |_, v_params|
        next if v_params[:_destroy] == "1" || v_params[:_destroy] == true # Skip deleted ones
        
        # Find the vehicle that was just updated/created by the update call above
        vehicle = @user.vehicles.find_by(id: v_params[:id])
        next unless vehicle # Safety check
        
        qr_code_id = v_params[:qr_code_id]
        if qr_code_id.present?
          new_qr = QrCode.find_by(id: qr_code_id)
          # Only update if it's actually changing to avoid unnecessary DB hits
          if new_qr && new_qr.votable != vehicle
            # Clear old QR if necessary (depending on your business logic)
            vehicle.qr_code.update(votable: nil) if vehicle.qr_code && vehicle.qr_code != new_qr
            new_qr.update!(votable: vehicle)
          end
        end
      end
  
      redirect_to (params[:redirect_url] || user_path(@user))
    else
      flash_alert_now 'We had a problem saving your updated information'
      flash_alert_now @user.errors.full_messages.to_sentence
      render action: :edit
    end
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
            :address1,
            :address2,
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
        :email, :password, :password_confirmation, 
        :first_name, :last_name, :address1, :address2, :city, :state_or_province, :postal_code, :country, :is_admin_created, 
        :citroenvie,
        vehicles_attributes:
            [:id, :year, :marque, :model, :other_info, :bringing, :for_sale, :qr_code_id, :_destroy]
      )
    end
end
