# lib/tasks/import_tables.rake
require 'csv'

namespace :import do
  desc "Import data from CSV files into the database"
  task :tables => :environment do
    # Define the tables to import with their models and CSV file paths
    tables = {
      "faqs" => "question",
      "scheduled_events" => "name",
      "vendors" => "name",
      "keyed_contents" => "key",
    }

    id_mapping = {}

    tables.each do |table_name, attrib|

      klass = table_name.singularize.camelize.constantize

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


          # Create the record using the attributes, handle potential issues with missing foreign key
          puts "Trying to import row: #{attributes}"
          begin
            existing_object = klass.where(attrib.to_sym => attributes[attrib]).first
            if existing_object
              new_object = existing_object.update!(attributes)
            else
              new_object = klass.create!(attributes)
              new_id += 1
            end
            puts "Success for #{attributes["name"]}"
            id_mapping[table_name][old_id] = new_object.id
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
