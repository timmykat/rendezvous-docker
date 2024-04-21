class Admin::UsersController < AdminController
  def cleanup
    @users = User.joins(:registrations)
    .group('users.id')
    .having('COUNT(registrations.id) = 0')
    # @users = @users.where("CAST(last_name AS BINARY) REGEXP BINARY ?", "[A-Z]{2}").all
    # @users = @users.where("BINARY last_name REGEXP ?", "^(?!(Mc|Mac|La|De))")
    # @users = @users.where("last_name REGEXP ?", "^(?![A-Z]+$)")
  end

  def delete_users
    @users_to_delete = User.find(params[:user_id])
    redirect_to admin_cleanup_path
  end
end