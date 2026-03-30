require 'semantic_logger'

SemanticLogger.default_level = Rails.env.production? ? :info : :debug


# STDOUT appender (Docker-friendly)
SemanticLogger.add_appender(
  io: $stdout,
  formatter: :default
)

# Wire into Rails
Rails.logger = SemanticLogger['Rails']
