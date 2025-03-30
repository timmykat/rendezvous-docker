class ChangeMarkdownFieldsFromStringToText < ActiveRecord::Migration[7.1]
  def up
    # Venues
    change_column :admin_venues, :address, :text
    change_column :admin_venues, :details, :text

    # FAQs
    change_column :admin_faqs, :question, :text
    change_column :admin_faqs, :response, :text

    # Scheduled Events
    change_column :admin_scheduled_events, :short_description, :text
    change_column :admin_scheduled_events, :long_description, :text
  end

  def down
    # Venues
    change_column :admin_venues, :address, :string
    change_column :admin_venues, :details, :string

    # FAQs
    change_column :admin_faqs, :question, :string
    change_column :admin_faqs, :response, :string

    # Scheduled Events
    change_column :admin_scheduled_events, :short_description, :string
    change_column :admin_scheduled_events, :long_description, :string
  end
end
