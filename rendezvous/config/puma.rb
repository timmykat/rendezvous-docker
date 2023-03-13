
# Min and max thread count
threads 1, 6

rackup      DefaultRackup if defined?(DefaultRackup)
port        ENV['PORT']     || 3000

# Default to production
rails_env = ENV['RAILS_ENV'] || "production"
environment rails_env

app_dir = File.expand_path("../..", __FILE__)

if rails_env == "production"
  workers 1

  shared_dir = "#{app_dir}/shared"

  # Set up socket location
  bind "unix://#{shared_dir}/sockets/puma.sock"

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
  ActiveRecord::Base.establish_connection(YAML.load_file("#{app_dir}/config/database.yml")[rails_env])
end