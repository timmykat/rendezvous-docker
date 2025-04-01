# lib/tasks/import_tables.rake
require 'csv'

namespace :import do
  desc "Import data from CSV files into the database"
  task :tables => :environment do
    # Define the tables to import with their models and CSV file paths
    tables = {
      "faqs" => {
        key: "question",
        omit_attribs: []
      },
      "scheduled_events" => {
        key: "name",
        omit_attribs: [
          "venue_id",
          "main_event_id",
          "has_subevents"
        ]
      },
      "vendors" =>  {
        key: "name",
        omit_attribs: []
      },
      "keyed_contents" => {
        key: "key",
        omit_attribs: []
      },
    }

    tables.each do |table_name, attrib_info|

      klass = table_name.singularize.camelize.constantize

      # Define the file path for the CSV
      file_path = Rails.root.join("import_files", "#{table_name}_exported.csv")

      if File.exist?(file_path)
        puts "Importing data for #{table_name} from #{file_path}"

        # Open and read the CSV file
        new_id = 1000
        CSV.foreach(file_path, headers: true) do |row|
          # Create a hash of attributes for the record to be imported
          attributes = row.to_hash

          # Delete the ID so it is auto generated
          attributes.delete("id")
          attrib_info[:omit_attribs].each do |attrib|
            attributes.delete[attrib] if attributes.keys.includes? attrib
          end

          # Create the record using the attributes, handle potential issues with missing foreign key
          puts "Trying to import row: #{attributes}"
          begin
            lookup_key = attrib_info[:key]
            existing_object = klass.where(lookup_key.to_sym => attributes[lookup_key]).first
            if existing_object
              new_object = existing_object.update!(attributes)
            else
              new_object = klass.create!(attributes)
              new_id += 1
            end
            puts "Success for #{attributes["name"]}"
          rescue ActiveRecord::ActiveRecordError => e
            puts "Failed to import row: #{attributes["name"]}. Error: #{e.message}"
          end
        end
      else
        puts "CSV file for #{table_name} not found at #{file_path}"
      end
    end
  end
end
