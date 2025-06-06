if defined?(Delayed::Worker)
  delayed_job_log = File.open(Rails.root.join('log', 'delayed_job.log'), 'a')
  delayed_job_log.sync = true
  Delayed::Worker.logger = Logger.new(delayed_job_log)
  Delayed::Worker.logger.level = Logger::INFO  # Or WARN to reduce noise
end