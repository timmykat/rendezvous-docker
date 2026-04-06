require 'semantic_logger'

SemanticLogger.default_level = Rails.env.production? ? :info : :debug

# Remove existing appenders
SemanticLogger.appenders.each do |appender|
  SemanticLogger.remove_appender(appender)
end

# Add only STDOUT (Docker-friendly)
SemanticLogger.add_appender(
  io: $stdout,
  formatter: :default
)

# Wire into Rails
Rails.logger = SemanticLogger['Rails']
