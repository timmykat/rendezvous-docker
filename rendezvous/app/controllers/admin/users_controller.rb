require 'valid_email2'

module Admin
  class UsersController < Admin::AdminController
    def delete_users
      users = User.where(id: params[:user_ids])
      number_of_users = users.size
      unless users.destroy_all
        flash_alert 'Something went wrong with user destruction'
        redirect_to admin_dashboard_path and return
      end

      redirect_to admin_dashboard_path, notice: "#{number_of_users} user(s) were deleted"
    end

    def deletion_candidates
      users = User.left_outer_joins(:registrations).where(registrations: { id: nil }).all
      @candidates = []
      users.each do |user|
        address = ValidEmail2::Address.new(user.email)
        record = {
          user: user,
          registrations: user.registrations&.size || 0,
          suspicious_name: suspicious_name?(user.last_name),
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

    def suspicious_name?(name)

      suspicious = false
      # Over 10 characters, not enough vowels
      suspicious ||= name.length > 10 && name.scan(/[aeiou]/i).size < 2
      # Random-like uppercase/lowercase pattern (multiple uppercase letters not at start)
      suspicious ||= !!(name =~ /[A-Z]{2,}[a-z]{2,}/)
      # No vowels at all
      suspicious ||= !(name =~ /[aeiou]/i)
      # Almost all letters are the same
      suspicious ||= name.chars.uniq.size < name.length - 2

      suspicious
    end
  end
end
