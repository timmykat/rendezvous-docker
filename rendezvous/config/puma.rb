
# Min and max thread count
threads 1, 6

rackup      DefaultRackup if defined?(DefaultRackup)
port        ENV['PORT']     || 3000

# Default to production
rails_env = ENV['RAILS_ENV'] || "production"
environment rails_env

if rails_env == "production"
  app_dir = "/var/www/rendezvous"
  db_config_path = "#{app_dir}/shared/config/database.yml"
else
  app_dir = File.expand_path("../..", __FILE__)
  db_config_path = "#{app_dir}/config/database.yml"
end

if rails_env == "production"
  workers 0

  shared_path = "#{app_dir}/shared"

  # Set up socket location
  bind "unix://#{shared_path}/sockets/puma.sock"

  # Logging
  stdout_redirect "#{shared_dir}/log/puma.stdout.log", "#{shared_dir}/log/puma.stderr.log", true

  # Set primary PID and state locations
  pidfile "#{shared_dir}/pids/puma.pid"
  state_path "#{shared_dir}/pids/puma.state"
  activate_control_app
end

preload_app!

on_worker_boot do
  require "active_record"

  ActiveRecord::Base.connection.disconnect! rescue ActiveRecord::ConnectionNotEstablished
  ActiveRecord::Base.establish_connection(YAML.load_file(db_config_path)[rails_env])
end