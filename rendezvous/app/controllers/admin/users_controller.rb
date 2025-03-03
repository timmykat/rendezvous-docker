class Admin::UsersController < AdminController
  def cleanup
    @users = get_deletion_candidates
    @users_to_delete = User.where(id: params[:user_ids])
    confirm_delete = params[:confirm_delete]
    if confirm_delete && !@users_to_delete.empty?
      @users_to_delete.destroy_all
      redirect_to admin_dashboard_path, notice: "Sus users deleted"
    end
  end

  def get_deletion_candidates
    users = User.left_outer_joins(:registrations).where(registrations: { id: nil }).all
    # users = @users.where("CAST(last_name AS BINARY) REGEXP BINARY ?", "[A-Z]{2}")
    # users = @users.where("CAST(last_name AS BINARY) REGEXP BINARY ?", "^(?!([A-Z]+))$")
    # @users = @users.where("BINARY last_name REGEXP ?", "^(?!(Mc|Mac|La|De))")
    # @users = @users.where("last_name REGEXP ?", "^(?![A-Z]+$)")
  end
end