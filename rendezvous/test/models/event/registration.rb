require "test_helper"

class Event::RegistrationTest < ActiveSupport::TestCase
  def build_registration(attrs = {})
    Event::Registration.new({
      user: users(:one), # assumes you have this fixture
      status: "new",
      number_of_adults: 1,
      registration_fee: 100,
      donation: 10,
      lake_cruise_fee: 65,
      paid_amount: 0,
      refunded: 0
    }.merge(attrs))
  end

  #
  # VALIDATIONS
  #

  test "valid with default attributes" do
    reg = build_registration
    assert reg.valid?
  end

  test "requires valid status" do
    reg = build_registration(status: "not real")
    assert_not reg.valid?
    assert_includes reg.errors[:status], "is not included in the list"
  end

  test "requires at least one adult unless cancelled" do
    reg = build_registration(number_of_adults: 0, status: "new")
    assert_not reg.valid?
    assert_includes reg.errors[:base], "You must register at least one adult."

    reg.status = "cancelled - settled"
    assert reg.valid?
  end

  test "paid amount cannot exceed total" do
    reg = build_registration(paid_amount: 200, registration_fee: 100)
    reg.valid?
    assert_includes reg.errors[:base], "The paid amount is more than the owed amount."
  end

  test "validates paid_method inclusion" do
    valid_method = Rails.configuration.registration[:payment_methods].first
    reg = build_registration(paid_method: valid_method)
    assert reg.valid?

    reg.paid_method = "invalid"
    assert_not reg.valid?
  end

  test "validates sunday_lunch_number bounds" do
    max = Rails.configuration.registration[:sunday_lunch_max]

    reg = build_registration(sunday_lunch_number: max + 1)
    assert_not reg.valid?

    reg.sunday_lunch_number = 0
    assert reg.valid?
  end

  test "validates lake_cruise_number bounds" do
    max = Rails.configuration.registration[:lake_cruise_max]

    reg = build_registration(lake_cruise_number: max + 1)
    assert_not reg.valid?

    reg.lake_cruise_number = 0
    assert reg.valid?
  end

  #
  # CALLBACKS
  #

  test "ensure_financials calculates total and balance" do
    reg = build_registration(
      registration_fee: 100,
      donation: 20,
      lake_cruise_fee: 10,
      paid_amount: 50,
      refunded: 5
    )

    reg.save!

    assert_equal 130, reg.total.to_f
    assert_equal 75, reg.balance.to_f # 130 - (50 + 5)
  end

  #
  # SCOPES
  #

  test "current scope filters by year" do
    current = build_registration(year: Date.current.year.to_s)
    old = build_registration(year: "1999")

    current.save!
    old.save!

    assert_includes Event::Registration.current, current
    assert_not_includes Event::Registration.current, old
  end

  #
  # INSTANCE METHODS
  #

  test "number_of_people returns attendees count" do
    reg = build_registration
    reg.save!

    reg.attendees.create!(name: "A")
    reg.attendees.create!(name: "B")

    assert_equal 2, reg.number_of_people
  end

  test "number_of_volunteers counts correctly" do
    reg = build_registration
    reg.save!

    reg.attendees.create!(name: "A", attendee_age: 'adult', volunteer: true)
    reg.attendees.create!(name: "Y", attendee_age: 'youth', volunteer: false)
    reg.attendees.create!(name: "C", attendee_age: 'child', volunteer: false)

    assert_equal 1, reg.number_of_volunteers
  end

  test "outstanding_balance? works" do
    reg = build_registration
    reg.balance = 10
    assert reg.outstanding_balance?

    reg.balance = 0
    assert_not reg.outstanding_balance?
  end

  test "owed_a_refund? works" do
    reg = build_registration
    reg.balance = -10
    assert reg.owed_a_refund?

    reg.balance = 0
    assert_not reg.owed_a_refund?
  end

  test "complete? works" do
    reg = build_registration(status: "complete")
    assert reg.complete?
  end

  test "cancelled? works" do
    reg = build_registration(status: "cancelled - settled")
    assert reg.cancelled?
  end

  test "was_paid sets status when fully paid" do
    reg = build_registration(paid_amount: 100)
    reg.save!

    reg.was_paid(100)
    assert_equal "complete - confirmed", reg.reload.status
  end

  #
  # CLASS METHODS
  #

  test "invoice_number generates first number correctly" do
    Event::Registration.stub(:pluck, []) do
      number = Event::Registration.invoice_number
      assert_match /CR\d{4}-101/, number
    end
  end

  test "invoice_number increments correctly" do
    Event::Registration.stub(:pluck, ["CR2025-105"]) do
      number = Event::Registration.invoice_number
      assert_match /CR\d{4}-106/, number
    end
  end
end
