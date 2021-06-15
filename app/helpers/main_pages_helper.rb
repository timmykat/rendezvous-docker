module MainPagesHelper
  def can_register?
    (current_user && (current_user.has_role? :admin)) || (Time.now > Rails.configuration.rendezvous[:registration_window][:open] && Time.now <= Rails.configuration.rendezvous[:registration_window][:close])
  end
end
