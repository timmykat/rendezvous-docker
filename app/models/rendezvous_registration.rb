class RendezvousRegistration < ActiveRecord::Base
  belongs_to :user
  has_many :attendees, :dependent => :destroy
  accepts_nested_attributes_for :user, :reject_if => lambda { |a| a[:email].blank? || a[:first_name].blank? || a[:last_name].blank? }
  accepts_nested_attributes_for :attendees
  
  validate :minimum_number_of_adults
  validates :paid_method, :inclusion => ['credit card', 'check']
  validates :invoice_number, :uniqueness => true
  
  serialize :events, JSON
  
  def minimum_number_of_adults
    if (number_of_adults < 1) 
      errors.add_to_base "You must register at least one adult."
    end
  end
  
  def self.fees
    {
      :registration => {
        :adult => 50,
        :child => 0
      },
      :events => {
        :ice_cream_social => 5
      }
    }
  end
  
  def self.months
    [
      ['[01]  January', '01'],
      ['[02]  February', '02'], 
      ['[03]  March', '03'],
      ['[04]  April', '04'],
      ['[05]  May', '05'],
      ['[06]  June', '06'],
      ['[07]  July', '07'],
      ['[08]  August', '08'],
      ['[09]  September', '09'],
      ['[10]  October', '10'],
      ['[11]  November', '11'],
      ['[12]  December', '12']
    ]
  end
  
  def self.years
    [*2016..2022]
  end
  
  def self.mailing_address_array
    [ 'Citroen Rendezvous, LLC', '245 Harvester Road', 'Orange, CT 06477-2929', 'United States' ]
  end
  
  def invoice_number
    @invoice_number || "RR#{Time.now.year}-#{RendezvousRegistration.last.pluck(:id) + 101}"
  end
end
