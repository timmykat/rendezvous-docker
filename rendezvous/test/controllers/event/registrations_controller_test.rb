# test/controllers/event/registrations_controller_test.rb

require "test_helper"

class Event::RegistrationsControllerTest < ActionDispatch::IntegrationTest

  test 'sets paid amount to 0 when paying by check' do
    registration = build(:registration, paid_method: 'cash or check')

    assert_equal 0.0, registration.paid_amount
  end

  test 'creates an invoice number' do
    registration = build(:registration)
    year = Date.current.year

    Registration.stub :invoice_number, "CR#{year}-999" do
      assert_equal "CR#{year}-999", registration.invoice_number
    end
  end

  test "creates a user if not logged in and user doesn't exist" do
    registration = create(:registration)

    assert_equal User, registration.user.class
  end

  test 'finds and updates existing user' do
    user = create(:user)
    registration = create(:registration)

    assert_equal user, registration.user
  end

  test 'updates the user when logged in' do
    user = create(:user)

    registration = create(:registration, user_attributes: { first_name: 'Jacques' })

    assert_equal 'Jacques', user.reload.first_name
  end
end
