class AdminController < ApplicationController
  before_action :require_admin
  
  def index
    @registrations = RendezvousRegistration.where("year = ? AND status IN (?)", Time.now.year, ['complete', 'payment due'])
    
    @data = {
      :registrants    => [],
      :citroens       => [],
      :non_citroens   => [],
      :attendees      => [],
      :adult          => 0,
      :child          => 0,
      :sunday_dinner  => 0,
      :volunteer      => 0,
      :financials     => {
        :registration_fees  => 0.0,
        :donations          => 0.0,
        :total              => 0.0,
        :paid               => 0.0,
        :due                => 0.0
      }
    }
    @registrations.each do |registration|
      @data[:registrants] << registration.user
      
      @data[:financials][:total]                += registration.total.to_f unless registration.total.blank?
      @data[:financials][:registration_fees]    += registration.registration_fee.to_f unless registration.registration_fee.blank?
      @data[:financials][:paid]                 += registration.paid_amount.to_f unless registration.paid_amount.blank?
      @data[:financials][:due]                  += registration.amount_due.to_f unless registration.amount_due.blank?
      @data[:financials][:donations]            += registration.donation.to_f unless registration.donation.blank?
      
      registration.user.vehicles.each do |v|
        if v.marque == 'Citroen'
          @data[:citroens]      << v
        else
          @data[:non_citroens]  << v
        end
      end
      
      registration.attendees.each do |a|
        @data[:attendees] << a.name
        @data[a.adult_or_child.to_sym]  += 1
        @data[:sunday_dinner]           += 1  if a.sunday_dinner?
        @data[:volunteer]               += 1  if a.volunteer?        
      end
    end
    
    @vehicles = @data[:citroens] + @data[:non_citroens]
    
    @users = User.all
  end
  
  def toggle_user_session
    session[:admin_user] = !session[:admin_user]
    redirect_to :back
  end
end
