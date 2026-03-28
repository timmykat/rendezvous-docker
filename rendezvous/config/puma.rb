rails_env = ENV.fetch("RAILS_ENV", "production")

app_dir = ENV.fetch("APP_DIR", "/var/www/rendezvous")

environment rails_env

pidfile "#{app_dir}/tmp/pids/puma.pid"
state_path "#{app_dir}/tmp/pids/puma.state"
log_dir = "#{app_dir}/log"
stdout_redirect "#{log_dir}/puma.stdout.log", "#{log_dir}/puma.stderr.log", true

threads 1, 5

if rails_env == "production"
  workers 2
  preload_app!
end

bind "tcp://0.0.0.0:3000"
