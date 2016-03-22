class UsersController < ApplicationController

  before_action :authenticate_user!, :only => [:edit, :update]

  def sign_up_or_in
  end
  
  def edit
    @user = current_user
    @rendezvous_registration = current_user.rendezvous_registrations.current.first
  end
  
  def update
    @user = User.find(params[:id])
    if !@user.update(user_params)
      flash[:alert] = 'We had a problem saving your updated information'
      render :action => :edit
    else
      flash[:notice] = 'Your user/vehicle information was updated.'
      redirect_to edit_user_path(@user)
    end
  end
  
  def join_mailing_list
    gibbon = Gibbon::Request.new   # Automatically uses   MAILCHIMP_API_KEY environment variable
    gibbon.timeout = 10
    
    gibbon.lists(Rails.configuration.mailchimp.list_id).members.create(body: {email_address: params[:email], status: "subscribed"})
  end
  
  def find_by_email
    if User.find_by_email(params[:email])
      status = { :exists => true }
    else
      status = { :exists => false }
    end
    render :json => status  
  end
  
  def toggle_admin
    user = User.find(params[:user_id])
    if params[:admin]
      user.roles << :admin
    else
      user.roles.delete :admin
    end
    render :json => true
  end

  private
    def user_params
      params.require(:user).permit(
        [:id, :email, :password, :password_confirmation, :first_name, :last_name, :address1, :address2, :city, :state_or_province, :postal_code, :country,
          {:vehicles_attributes => 
            [:id, :year, :marque, :model, :other_info, :_destroy]
          }
        ]
      )
    end

end