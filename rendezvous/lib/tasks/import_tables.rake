# lib/tasks/import_tables.rake
require 'csv'

namespace :import do
  desc "Import data from CSV files into the database"
  task :tables => :environment do
    # Define the tables to import with their models and CSV file paths
    tables = [
      "faqs" => Faq,
      "scheduled_events" => ScheduledEvent,
      "vendors" => Vendor,
      "keyed_contents" => KeyedContent
  ]

    id_mapping = {}

    tables.each do |table_name, klass|

      if klass.respond_to?(:establish_connection)
        # This might be needed if you're using multiple databases
        klass.establish_connection(klass.connection_config)
      end
      
      id_mapping[table_name] = {}

      # Define the file path for the CSV
      file_path = Rails.root.join("import_files", "#{table_name}_exported.csv")

      if File.exist?(file_path)
        puts "Importing data for #{table_name} from #{file_path}"

        # Open and read the CSV file
        new_id = 1000
        CSV.foreach(file_path, headers: true) do |row|
          # Create a hash of attributes for the record to be imported
          attributes = row.to_hash
          old_id = row['id']

          # Delete the ID so it is auto generated
          attributes.delete("id")

          # Resolve foreign keys for associations
          if table_name == "scheduled_events"
            # For scheduled_events, we need to map venue_id from the venues table
            venue = Venue.find_by(name: attributes["name"])  # assuming venue_name is in the CSV
            attributes["venue_id"] = venue.id if venue
          end

          # Create the record using the attributes, handle potential issues with missing foreign key
          begin
            new_object = klass.create!(attributes)
            new_id += 1
            puts "Imported row: #{attributes}"
            id_mapping[table_name][old_id] = new_object.id
          rescue ActiveRecord::RecordInvalid => e
            puts "Failed to import row: #{attributes}. Error: #{e.message}"
          end
        end

        if table_name == "scheduled_events"
          # Update sub_events
          sub_events = ScheduledEvent.where.not(main_event_id: nil)
          sub_events.each do |sub|
            puts "Updating: #{sub.name} with new ID: #{id_mapping['scheduled_events'][sub.main_event_id]} "
            sub.main_event_id = id_mapping['scheduled_events'][sub.main_event_id]
          end
        end
      else
        puts "CSV file for #{table_name} not found at #{file_path}"
      end
    end
  end
end
