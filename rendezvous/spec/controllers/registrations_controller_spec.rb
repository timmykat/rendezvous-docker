require 'rails_helper'

RSpec.describe Event::RegistrationsController, type: :controller do

  before(:each) do
    DatabaseCleaner.start
  end
  
  context "the user is paying by credit card" do
    context "the transaction succeeds" do
      before(:each) do
        @registration = build(:registration)
        Braintree::Transaction.stub(:sale).and_return(double('result', :success? => true))
      end
      
      it "sets the paid amount" do
        expect(@registration.paid_amount).to be_equal(100.0)
      end
      
      it "sets the paid method" do
        expect(@registration.paid_method).to be_equal('credit card')
      end
      
      it "redirects to the show page" do
        expect(@registration).to redirect_to(assigns(:registration))
      end
    end
    
    context "the transaction fails" do
      before(:each) do
        @registration = build(:registration)
        Braintree::Transaction.stub(:sale).and_return(double('result', {:success? => false, transaction: true, errors: 'There was an error' }))
      end
    
      it "sets a flash error"
      
      it "it rerenders the form" do
        expect(response).to render_template("new")
      end 
    end
  end
  
  context "the user is paying by check" do
    it "sets the paid amount to 0" do
      @registration = build(:registration, paid_method: 'check')
      expect(@registration.paid_amount).to be_equal(0.0)
    end
  end

  it "creates an invoice number" do
    @registration = build(:registration)
    year = Time.now.year
    Registration.stub(:invoice_number).and_return("CR#{year}-999")
    expect(@registration.invoice_number).to be_equal("CR#{year}-999")
  end

  context "user not logged in" do
    context "user doesn't exist" do
      it "creates a user" do
        @registration = create(:registration)
        expect(@registration.user.class).to be_equal('User')
      end
    end

    context "user does exist" do
      it "finds and updates the user" do
        @user = create(:user)
        @registration = create(:registration)
        expect(@registration.user).to be_equal(@user)
      end
    end
  end
  
  context "user logged in" do    
    it "updates the user" do
      @user = create(:user)
      @registration = create(:registration, user_attributes: { first_name: "Jacques" })
      expect(@user.first_name).to be_equal("Jacques")
    end
  end
  
end
