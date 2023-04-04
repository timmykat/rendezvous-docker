
# Min and max thread count
threads 1, 6

rackup      DefaultRackup if defined?(DefaultRackup)
port        ENV['PORT']     || 3000

# Default to production
rails_env = ENV['RAILS_ENV'] || "production"
environment rails_env



if !Dir.exists? "/proc/docker"
  app_dir = "/var/www/rendezvous/current"
  shared_dir = "#{app_dir}/shared"
  db_config_file = "#{shared_dir}/config/database.yml"
  puma_socket_file = "#{shared_dir}/sockets/puma.sock"
  puma_state_file = "#{shared_dir}/pids/puma.state"
  pidfile "#{shared_dir}/pids/puma.pid"
  log_dir = "#{shared_dir}/log"

  workers 1

else
  app_dir = "/var/www/rendezvous"
  db_config_file = "#{app_dir}/config/database.yml"
  puma_socket_file = "#{app_dir}/tmp/sockets/puma.sock"
  puma_state_file = "#{app_dir}/tmp/pids/puma.state"
  pidfile "#{app_dir}/tmp/pids/puma.pid"
  log_dir = "#{app_dir}/log"

  puts "*** Puma socket: #{puma_socket_file}"
end

# Bind puma socket
bind "unix:/#{puma_socket_file}"

state_path puma_state_file

# Logging
stdout_redirect "#{log_dir}/puma.stdout.log", "#{log_dir}/puma.stderr.log", true

# Set primary PID and state locations

activate_control_app

preload_app!

on_worker_boot do
  puts "** Setting socket permissions **"
  puts `chmod ago+rw #{puma_socket_file}`
  require "active_record"

  puts "Booting worker"

  ActiveRecord::Base.connection.disconnect! rescue ActiveRecord::ConnectionNotEstablished
  ActiveRecord::Base.establish_connection(YAML.load_file(db_config_file)[rails_env])
end