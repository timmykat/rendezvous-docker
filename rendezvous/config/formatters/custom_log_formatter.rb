class CustomLogFormatter < Logger::Formatter
  def call(severity, time, progname, msg)
    caller_info = caller(1..1).first
    file_line = extract_app_caller
    "#{time.utc.iso8601} [#{severity}] #{file_line} - #{msg}\n"
  end

  private
  def extract_app_caller
    caller.each do |line|
      file = line.split(':').first
      next if file.include?('/gems/') || file.include?('custom_log_formatter.rb')

      # Found a good candidate inside Rails.root
      if file.start_with?(Rails.root.to_s)
        relative_file = Pathname.new(file).relative_path_from(Rails.root).to_s
        line_number = line.split(':')[1]
        return "#{relative_file}:#{line_number}"
      end
    end
  end
end