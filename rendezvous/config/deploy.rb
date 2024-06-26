# config valid only for current version of Capistrano
lock '3.18.1'

# Test for shell, presence of yarn
on roles(:web) do
  execute :echo, '$SHELL'
  execute :which, 'yarn'
end

set :application, 'rendezvous'

# Use github repository
# set :repo_url, 'git@github.com:timmykat/rendezvous.git'
set :repo_url, 'git@github.com:timmykat/rendezvous-docker.git'

# Default branch is :master
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
# set :branch, 'main'

# Set app directory for dockerized version
set :repo_tree, 'rendezvous'

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push(
  '.env', 'dkim.pem', 'config/database.yml', 'config/secrets.yml', 'config/puma.rb'
)

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push(
  'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/files', 'public/uploads'
)

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 3

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      invoke 'puma:stop'
      invoke 'puma:start'
    end
  end

end
