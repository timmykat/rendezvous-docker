# config valid only for Capistrano 3.1
lock '3.1.0'

set :rvm_ruby_string, :local
set :rvm_autolibs_flag, 'install-packages'

set :application, 'ofx'
set :repo_url, 'ssh://ec2-user@ec2-54-186-175-209.us-west-2.compute.amazonaws.com/home/ec2-user/git-repos/ofx-staging.git'
set :stages, %w(staging production)

set :ssh_options, { keys: '~/.ssh/ofx-amazon.pem', forward_agent: true}

# Default branch is :master
ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# Set deploy user
set :user, 'ec2-user'

# Set environment (testing production)
set :rails_env, 'production'


# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/var/www/ofx'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/documentation}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do
  task :show_tasks do
    exec("cd #{deploy_to}/current; /usr/bin/rake -T")
  end

  desc 'Restart application'
  task :restart do
    on roles(:web), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end
end
