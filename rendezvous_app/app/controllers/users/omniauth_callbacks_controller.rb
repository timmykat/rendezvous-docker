# class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
#     
# #   def facebook
# #     @user = User.from_omniauth(env["omniauth.auth"])
# #     sign_in_and_redirect @user, event: :authentication
# #       set_flash_message(:notice, :success, kind: "#{provider}".capitalize) if is_navigational_format?
# #     else
# #       session["devise.#{provider}_data"] = env["omniauth.auth"]
# #       redirect_to sign_in_url
# #     end
# #   end
# # 
# #   def failure
# #     redirect_to root_path
# #   end
# end