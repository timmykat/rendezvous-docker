Delayed::Worker.sleep_delay = 180
Delayed::Worker.logger = Logger.new(Rails.root.join('log', 'delayed_job.log'))