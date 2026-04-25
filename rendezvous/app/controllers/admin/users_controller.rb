require 'valid_email2'

module Admin
  class UsersController < Admin::AdminController
    def cleanup
      @users = deletion_candidates
      @users_to_delete = User.where(id: params[:user_ids])
      confirm_delete = params[:confirm_delete]
      unless confirm_delete && !@users_to_delete.empty?
        redirect_to admin_dashboard_path, notice: 'No deletions' and return
      end

      @users_to_delete.destroy_all
      redirect_to admin_dashboard_path, notice: 'Sus users deleted'
    end

    def deletion_candidates
      users = User.left_outer_joins(:registrations).where(registrations: { id: nil }).all
      @candidates = []
      users.each do |user|
        address = ValidEmail2::Address.new(user.email)
        record = {
          user: user,
          valid: address.valid?,
          deny_list: address.deny_listed?,
          disposable: address.disposable?,
          valid_mx: address.valid_mx?,
          subaddressed: address.subaddressed?
        }
        @candidates << record
      end
      @candidates
    end
  end
end
