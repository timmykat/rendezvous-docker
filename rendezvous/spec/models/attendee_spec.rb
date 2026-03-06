# == Schema Information
#
# Table name: attendees
#
#  id              :integer          not null, primary key
#  attendee_age    :string(255)      default("adult")
#  name            :string(255)
#  sunday_dinner   :boolean
#  volunteer       :boolean
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  registration_id :integer
#
# Indexes
#
#  index_attendees_on_attendee_age   (attendee_age)
#  index_attendees_on_sunday_dinner  (sunday_dinner)
#  index_attendees_on_volunteer      (volunteer)
#
require 'rails_helper'

RSpec.describe Attendee, type: :model do

  it "has a valid factory" do
    expect(build(:attendee)).to be_valid
  end
  
  it "is invalid without a name" do
    expect(build(:attendee, name: nil)).to be_invalid
  end
  
  it "must be an adult or a child" do
    expect(build(:attendee, attendee_age: nil)).to be_invalid
  end
  
  DatabaseCleaner.clean_with :truncation
  DatabaseCleaner.strategy = :transaction
  DatabaseCleaner.start
    
  context 'multiple attendees' do
    
    before(:each) do
      @sunday_diners_and_volunteers = create_list(:attendee, 2, sunday_dinner: true, volunteer: true) 
      @sunday_diners = create_list(:attendee, 3, sunday_dinner: true) 
      @volunteers = create_list(:attendee, 4, volunteer: true) 
      @neither = create_list(:attendee, 7) 
      @kids = create_list(:attendee, 2, attendee_age: 'child') 
    end
    
    it "returns the number of sunday diners" do
      expect(Attendee.sunday_dinner_count).to be_equal(@sunday_diner_volunteers.count + @sunday_diner_only.count)
    end

    it "returns the number of volunteers" do
      expect(Attendee.volunteer_count).to be_equal(@sunday_diner_volunteers.count + @volunteer_only.count)
    end
    
    it "returns the number of adults" do
      expect(Attendee.adult_count).to be_equal(@sunday_diners_and_volunteers.count + @volunteers.count + @sunday_diners.count + @neither.count)
    end

    it "returns the number of kids" do
      expect(Attendee.adult_count).to be_equal(@kids.count)
    end
  end
end
