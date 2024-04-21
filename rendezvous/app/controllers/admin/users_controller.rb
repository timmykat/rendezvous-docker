class Admin::UsersController < AdminController
  def cleanup
    @users = get_users
  end

  def delete_users
    Rails.logger.debug("****")
    Rails.logger.debug(params.inspect)
    @users_to_delete = User.where(id: params[:user_ids])
    @users = get_users
    redirect_to admin_cleanup_path
  end

  def get_users
    users = User.left_outer_joins(:registrations).where(registrations: { id: nil })
    users = @users.where("CAST(last_name AS BINARY) REGEXP BINARY ?", "[A-Z]{2}").all
    # @users = @users.where("BINARY last_name REGEXP ?", "^(?!(Mc|Mac|La|De))")
    # @users = @users.where("last_name REGEXP ?", "^(?![A-Z]+$)")
  end

  def users_to_delete_params
    params.require(:user_ids)
  end
end