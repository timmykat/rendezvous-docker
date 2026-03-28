class Devise::CustomFailure < Devise::FailureApp
  def redirect_url
    if request.path.start_with?('/sidekiq')
      '/'
    elsif scope == :user
      send(:"new_#{scope}_session_path")
    else
      super
    end
  end

  def respond
    http_auth? ? http_auth : redirect
  end
end
