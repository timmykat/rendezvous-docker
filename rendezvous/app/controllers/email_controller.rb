class EmailController < ApplicationController

  before_action :authenticate_user!

  def create_message
    reg = Event::Registration.find(params[:r_id])
    @name = reg.user.full_name
    @email = reg.user.email
    @reg_link = event_registration_url(reg.id)
    @topic = params[:topic]&.to_sym || 'General Message'
  end

  def send_message
    RendezvousMailer.with(
      subject: email_params[:subject],
      name: email_params[:name],
      email: email_params[:email],
      registration_link: email_params[:registration_link],
      topic: email_params[:topic],
      message: email_params[:message]
    ).send_user_message.deliver_later
    flash_notice 'Your message has been sent.'
    redirect_to email_params[:registration_link]
  end

  private

  def email_params
    params.require(:message_request)
      .permit(
        :subject,
        :name,
        :email,
        :registration_link,
        :topic,
        :message
      )
  end
end
