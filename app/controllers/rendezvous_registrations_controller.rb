class RendezvousRegistrationsController < ApplicationController

  def new
    @app_data = ActiveSupport::JSON.encode(
      {
        :clientToken => Braintree::ClientToken.generate,
        :fees => RendezvousRegistration.fees
      }
    )
 
    @rendezvous_registration = RendezvousRegistration.new
    @rendezvous_registration.attendees.build
    user = @rendezvous_registration.build_user
    user.vehicles.build
  end

  def create
    unless params[:rendezvous_registration][:paid_method] == 'check' || params[:payment_method_nonce].blank?
      result = Braintree::Transaction.sale(
        :amount => params[:rendezvous_registration][:amount],
        :payment_method_nonce => params[:payment_method_nonce],
        :options => {
          :submit_for_settlement => true
        },
      )
      
    
      if result.success?
        params[:rendezvous_registration][:amount] = params[:rendezvous_registration][:amount].to_f
        params[:rendezvous_registration][:paid_amount] = params[:rendezvous_registration][:amount]
        params[:rendezvous_registration][:paid_method] = 'credit card'
        params[:rendezvous_registration][:paid_date] = Time.new
        
        @rendezvous_registration = RendezvousRegistration.new(rendezvous_registration_params)
        if @rendezvous_registration.save!
          flash[:alert] = "You have successfully registered for the Rendezvous. Looking forward to seeing you!"
          redirect_to :root
        else
          flash[:error] = ''
          @rendezvous_registration.each do |error|
            flash[:error] += "<p>#{error}</p>".html_safe
          end
          render 'rendezvous_registrations/new'
        end
          
      elsif result.transaction
        flash[:error] = ''
        result.errors.for(:customer).each do |error|
          flash[:error] += "<p>#{error}</p>".html_safe
        end
        render 'rendezvous_registrations/new'
      end
    else
      params[:rendezvous_registration][:amount] = params[:rendezvous_registration][:amount].to_f
      params[:rendezvous_registration][:paid_amount] = 0.00
      params[:rendezvous_registration][:paid_method] = 'none'
      @rendezvous_registration = RendezvousRegistration.new(rendezvous_registration_params)
      if @rendezvous_registration.save!
        flash[:alert] = "You have registered for the Rendezvous but you have not paid. Please send a check for $#{@rendezvous_registration.amount} payable to Citroen Rendezvous, LLC to #{RendezvousRegistration.mailing_address_array.join(', ')}."
        redirect_to :root
      else
        flash[:error] = "There was a problem saving your registration."
        render 'rendezvous_registrations/new'
      end
    end
  end
  
  def index
    @rendezvous_registrations = RendezvousRegistration.all
  end
  
  
  private
    def rendezvous_registration_params
      params.require(:rendezvous_registration).permit(
        {:user_attributes => 
          [:id, :email, :password, :password_confirmation, :first_name, :last_name, :address1, :address2, :city, :state_or_province, :postal_code, :country,
            {:vehicles_attributes => 
              [:id, :year, :marque, :other_marque, :model, :other_model, :other_info, :_destroy]
            }
          ]
        },
        { :attendee_attributes =>
          [:id, :name, :adult_or_child, :volunteer, :sunday_dinner, :_destroy]
        },
        :number_of_adults,
        :number_of_children,
        :amount,
        :donation,
        :year, 
        :paid_amount,
        :paid_method,
        :paid_date
      )
    end
end
