
# Min and max thread count
threads 1, 6

rackup      DefaultRackup if defined?(DefaultRackup)
port        ENV['PORT']     || 3000

# Default to production
rails_env = ENV['RAILS_ENV'] || "production"
environment rails_env

if rails_env == "production"
  app_dir = "/var/www/rendezvous"
  shared_dir = "#{app_dir}/shared"
  db_config_file = "#{shared_dir}/config/database.yml"
  puma_socket_path = "#{shared_dir}/sockets/puma.sock"
  puma_state_path = "#{shared_dir}/pids/puma.state"
  log_directory = "#{shared_dir}/log"

  workers 1

  # Set up socket location
  bind "unix://#{puma_socket_path}"

  # Logging
  stdout_redirect "#{shared_dir}/log/puma.stdout.log", "#{shared_dir}/log/puma.stderr.log", true

  # Set primary PID and state locations
  pidfile "#{shared_dir}/pids/puma.pid"
  state_path "#{shared_dir}/pids/puma.state"
  activate_control_app

else
  app_dir = File.expand_path("../..", __FILE__)
  db_config_file = "#{app_dir}/config/database.yml"
end

puts "App dir: " + app_dir

puts "DB config path: " + db_config_path


preload_app!

on_worker_boot do
  require "active_record"

  puts "Booting worker"

  ActiveRecord::Base.connection.disconnect! rescue ActiveRecord::ConnectionNotEstablished
  ActiveRecord::Base.establish_connection(YAML.load_file(db_config_file)[rails_env])
end