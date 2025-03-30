require 'rails_helper'

RSpec.describe Event::RegistrationsController, type: :controller do

  before(:each) do
    DatabaseCleaner.start
  end
  
  context "the user is paying by check" do
    it "sets the paid amount to 0" do
      @event_registration = build(:registration, paid_method: 'cash or check')
      expect(@event_registration.paid_amount).to be_equal(0.0)
    end
  end

  it "creates an invoice number" do
    @event_registration = build(:registration)
    year = Time.now.year
    Registration.stub(:invoice_number).and_return("CR#{year}-999")
    expect(@event_registration.invoice_number).to be_equal("CR#{year}-999")
  end

  context "user not logged in" do
    context "user doesn't exist" do
      it "creates a user" do
        @event_registration = create(:registration)
        expect(@event_registration.user.class).to be_equal('User')
      end
    end

    context "user does exist" do
      it "finds and updates the user" do
        @user = create(:user)
        @event_registration = create(:registration)
        expect(@event_registration.user).to be_equal(@user)
      end
    end
  end
  
  context "user logged in" do    
    it "updates the user" do
      @user = create(:user)
      @event_registration = create(:registration, user_attributes: { first_name: "Jacques" })
      expect(@user.first_name).to be_equal("Jacques")
    end
  end
  
end
