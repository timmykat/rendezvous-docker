require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(
      email: "user@example.com",
      password: "Abc12345",
      password_confirmation: "Abc12345",
      first_name: "Timmy",
      last_name: "Kat",
      city: "Ottawa"
    )
  end

  # === Validations ===
  test "valid user" do
    assert @user.valid?
  end

  test "invalid without first_name" do
    @user.first_name = nil
    assert_not @user.valid?
    assert_includes @user.errors[:first_name], "can't be blank"
  end

  test "invalid without last_name" do
    @user.last_name = nil
    assert_not @user.valid?
    assert_includes @user.errors[:last_name], "can't be blank"
  end

  test "invalid without email" do
    @user.email = nil
    assert_not @user.valid?
    assert_includes @user.errors[:email], "can't be blank"
  end

  test "invalid with bad email format" do
    @user.email = "bademail"
    assert_not @user.valid?
    assert_includes @user.errors[:email], "is invalid"
  end

  test "rejects non-complex passwords" do
    @user.password = @user.password_confirmation = "password"
    assert_not @user.valid?
    assert_includes @user.errors[:password].join, "must include 1 of each"
  end

  test "allows password with complexity" do
    @user.password = @user.password_confirmation = "Abc123"
    assert @user.valid?
  end

  # === Associations check ===
  test "has many pictures" do
    assert_respond_to @user, :pictures
  end

  test "has many vehicles" do
    assert_respond_to @user, :vehicles
  end

  test "has many registrations" do
    assert_respond_to @user, :registrations
  end

  test "has many authorizations" do
    assert_respond_to @user, :authorizations
  end

  test "has one vendor" do
    assert_respond_to @user, :vendor
  end

  test "has many donations" do
    assert_respond_to @user, :donations
  end

  test "has many square_transactions" do
    assert_respond_to @user, :square_transactions
  end

  # === Custom instance methods ===
  test "full_name returns first and last name" do
    assert_equal "Timmy Kat", @user.full_name
  end

  test "last_name_first returns formatted name" do
    assert_equal "Kat, Timmy", @user.last_name_first
  end

  test "display_name is alias for full_name" do
    assert_equal @user.full_name, @user.display_name
  end

  test "generate_password sets password and confirmation" do
    @user.generate_password
    assert_equal @user.password, @user.password_confirmation
    assert_match /[A-Z]/, @user.password
    assert_match /[a-z]/, @user.password
    assert_match /[0-9]/, @user.password
    assert_operator @user.password.length, :>=, 8
  end

  test "generate_email_address assigns email in correct format" do
    @user.last_name = "Smith"
    @user.generate_email_address
    assert_match /^Smith_\w{4}@citroenrendezvous\.org$/, @user.email
  end

  test "#attending returns false with no current registration" do
    @user.save! # so registrations can be assigned
    assert_not @user.attending
  end

  test "#attending returns true when has current registration" do
    @user.save!
    Event::Registration.create!(user: @user, year: Date.current.year, created_at: Time.current)
    assert @user.attending
  end

  test "#newbie? returns true for one current year registration" do
    @user.save!
    Event::Registration.create!(user: @user, year: Date.current.year, created_at: Time.current)
    assert @user.newbie?
  end

  test "#newbie? returns false if more than one registration" do
    @user.save!
    Event::Registration.create!(user: @user, year: Date.current.year, created_at: Time.current)
    Event::Registration.create!(user: @user, year: Date.current.year, created_at: 1.day.ago)
    assert_not @user.newbie?
  end

  # === Scopes and class methods ===
  test "with_current_registration includes user with current year registration" do
    @user.save!
    Event::Registration.create!(user: @user, year: Date.current.year, created_at: Time.current)
    assert_includes User.with_current_registration, @user
  end

  test "with_registrations includes user with any registration" do
    @user.save!
    Event::Registration.create!(user: @user, year: Date.current.year, created_at: Time.current)
    assert_includes User.with_registrations, @user
  end

  test "ordered_by_current_year_registration puts registered first" do
    user1 = User.create!(
      first_name: "A",
      last_name: "Alpha",
      email: "registered1@example.com",
      password: "Abc12345",
      password_confirmation: "Abc12345",
      city: "X"
    )
    user2 = User.create!(
      first_name: "B",
      last_name: "Beta",
      email: "registered2@example.com",
      password: "Abc12345",
      password_confirmation: "Abc12345",
      city: "Y"
    )
    Event::Registration.create!(user: user1, year: Date.current.year, created_at: Time.current)
    assert_equal [user1, user2], User.ordered_by_current_year_registration
  end

  test 'find_by_token returns user with matching login token' do
    @user.save!(validate: false)
    @user.update_column(:login_token, 'sometoken')
    User.stub_any_instance(:digest, 'sometoken') do # Mock Devise.token_generator.digest
      assert_equal @user, User.find_by_token('sometoken')
    end
  end

  # === Custom validation for postal code, using a stub for configuration ===
  test "postal code validation for CA province" do
    @user.state_or_province = "Quebec"
    @user.postal_code = "K1A 0B1"
    Rails.stub(:configuration, OpenStruct.new(geodata: {provinces: ["Quebec"]})) do
      @user.valid?
      assert_empty @user.errors[:postal_code], "Should allow valid Canadian postal code"

      @user.postal_code = "12345"
      @user.valid?
      refute_empty @user.errors[:postal_code], "Should not allow invalid CA postal code"
    end
  end

  test "postal code validation for US state" do
    @user.state_or_province = "New York"
    @user.postal_code = "13323"
    Rails.stub(:configuration, OpenStruct.new(geodata: {provinces: []})) do
      @user.valid?
      assert_empty @user.errors[:postal_code], "Should allow valid US zip code"

      @user.postal_code = "K1A 0B1"
      @user.valid?
      refute_empty @user.errors[:postal_code], "Should not allow invalid US zip code"
    end
  end

  test "calls set_country before save" do
    user = User.new(
      email: "test@example.com",
      first_name: "Test",
      last_name: "Test",
      city: "City",
      password: "Abc12345",
      password_confirmation: "Abc12345",
      state_or_province: "Quebec"
    )
    user.singleton_class.class_eval { attr_accessor :set_country_called }
    def user.set_country
      self.set_country_called = true
    end
    user.save(validate: false)
    assert user.set_country_called, "Expected set_country to be called before save"
  end
end
