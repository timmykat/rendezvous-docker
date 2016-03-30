class Devise::CustomFailure < Devise::FailureApp 
  def redirect_url 
    if warden_options[:scope] == :user 
      sign_up_or_in_path 
    end
  end
   
  def respond 
    if http_auth? 
      http_auth 
    else 
      redirect 
    end 
  end 
end 
