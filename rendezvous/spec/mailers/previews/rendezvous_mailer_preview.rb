# Preview all emails at http://localhost:3000/rails/mailers/mailer
class RendezvousMailerPreview < ActionMailer::Preview
  def  def send_registration_open_notice
      RendezvousRendezvousMailer.send_registration_open_notice(
        User.new(first_name: 'Tim', last_name: 'Kinnel', email: 'tim@example.com')
      end
  end
end
