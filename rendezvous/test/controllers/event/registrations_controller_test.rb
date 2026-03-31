# test/controllers/event/registrations_controller_test.rb
require 'test_helper'

module Event
  class RegistrationsControllerTest < ActionDispatch::IntegrationTest

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

    test 'updates the user when logged in' do
      user = create(:user)

      registration = create(:registration, user_attributes: { first_name: 'Jacques' })

      assert_equal 'Jacques', user.reload.first_name
    end
  end
end
