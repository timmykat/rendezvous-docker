class EmailLink < ActiveRecord::Base
  belongs_to :user
  after_create :send_mail

  def self.generate(email)
    user = User.find_by(email: email)
    
    return nil if !user

    token = create(user: user, expires_at: Date.today + 1.day, token: generate_token)
    return token, user
  end

  def self.generate_token
    Devise.friendly_token.first(16)
  end

  private
  def send_mail
    EmailLinkMailer.sign_in_mail(self).deliver_now
  end
end

