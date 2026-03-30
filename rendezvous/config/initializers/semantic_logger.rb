require 'semantic_logger'

SemanticLogger.default_level = Rails.env.production? ? :info : :debug

# File appender (persistent logs)
SemanticLogger.add_appender(
  file_name: Rails.root.join("log/#{Rails.env}.log").to_s,
  formatter: :default
)

# STDOUT appender (Docker-friendly)
SemanticLogger.add_appender(
  io: $stdout,
  formatter: :default
)

# Wire into Rails
Rails.logger = SemanticLogger['Rails']
