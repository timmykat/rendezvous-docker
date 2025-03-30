# lib/tasks/export_tables.rake
namespace :export do
  desc "Export tables to CSV files (preserves IDs)"
  task :tables => :environment do
    # Define the tables to export
    tables = {
      "faqs" => Faq,
      "venues" => Venue,
      "scheduled_events" => ScheduledEvent,
      "vendors" => Vendor,
      "keyed_contents" => KeyedContent
    }

    tables.each do |table_name, klass|
      # Define the file path for the CSV
      file_path = Rails.root.join("import_files", "#{table_name}_exported.csv")

      # Open the CSV file and write the data
      CSV.open(file_path, "wb") do |csv|
        # Fetch column names for the header row
        csv << klass.column_names
        
        # Fetch all records and write them to CSV
        klass.find_each do |record|
          csv << record.attributes.values
        end
      end

      puts "Exported #{table_name} to #{file_path}"
    end
  end
end
