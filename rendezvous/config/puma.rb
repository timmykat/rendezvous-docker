
# Min and max thread count
threads 1, 6

rackup      DefaultRackup if defined?(DefaultRackup)
port        ENV['PORT']     || 3000

# Default to production
rails_env = ENV['RAILS_ENV'] || "production"
environment rails_env

app_dir = "/var/www/rendezvous"
db_config_file = "#{app_dir}/config/database.yml"
puma_state_file = "#{app_dir}/tmp/pids/puma.state"
pidfile "#{app_dir}/tmp/pids/puma.pid"
log_dir = "#{app_dir}/log"

# Bind puma socket
bind 'tcp://0.0.0.0:3000'

state_path puma_state_file

# Logging
stdout_redirect "#{log_dir}/puma.stdout.log", "#{log_dir}/puma.stderr.log", true

# activate_control_app
preload_app!
