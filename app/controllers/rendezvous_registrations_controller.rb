class RendezvousRegistrationsController < ApplicationController

  def get_client_token
    client_token = Braintree::ClientToken.generate
    render :text => client_token
  end

  def new
    @rendezvous_registration = RendezvousRegistration.new
    user = @rendezvous_registration.build_user
    user.vehicles.build
  end

  def create
    @rendezvous_registration = RendezvousRegistration.new(rendezvous_registration_params)
    result = Braintree::Transaction.sale 
  end
  
  # This handles the submission of the payment details via ajax
  def process_transaction
    result = Braintree::Transaction.sale(
      :amount => params[:rendezvous_registration][:amount],
      :payment_method_nonce => nonce_from_the_client,
      :billing => {
        :street_address => params[:rendezvous_registration][:user_attributes][:address_1],
        :extended_address => params[:rendezvous_registration][:user_attributes][:address_2],
        :locality_name => params[:rendezvous_registration][:user_attributes][:city], 
        :postal_code => params[:rendezvous_registration][:user_attributes][:postal_code], 
        :region => params[:rendezvous_registration][:user_attributes][:state_or_province],
        :country_code_alpha2 => params[:rendezvous_registration][:user_attributes][:country],
      },
      :options => {
        :submit_for_settlement => true
      },
      :cardholder_name => "#{params[:rendezvous_registration][:user_attributes][:first_name]} #{params[:rendezvous_registration][:user_attributes][:last_name]}",
      :cvv => params[:cvv],
      :expiration_month => params[:expiration_month],
      :expiration_month => params[:expiration_year]    
    )
  end
  
  private
    def rendezvous_registration_params
      params.require(:rendezvous_registration).permit(
        {:user_attributes => 
          [:id, :email, :first_name, :last_name, :address1, :address2, :city, :state_province, :post_code, :country,
            {:vehicle_attributes => 
              [:year, :marque, :other_marque, :model, :other_model, :other_info]
            }
          ]
        },
        :number_of_adults,
        :number_of_children,
        :amount,
        :year
      )
    end
end
