git_plugin = self

NGINX_PATH = '/etc/nginx'
CONF_FILE = 'nginx.conf'
LOCAL_CONF_DIRECTORY = 'config/nginx/production'
local_file = Pathname.new("#{RAILS_ROOT}/../#{LOCAL_CONF_DIRECTORY}/#{CONF_FILE}").cleanpath

namespace :nginx do
  desc 'Upload a new nginx config file'
  task :upload do
    on roles(:all) do
      local_file = Pathname.new("#{RAILS_ROOT}/../#{LOCAL_CONF_DIRECTORY}/#{CONF_FILE}").cleanpath
      upload(local_file, $HOME)
      execute :sudo, :cp, "#{$HOME}/nginx.conf", nginx_path
      end
    end
  end
end

namespace :nginx do
  desc 'Download the current nginx config file'
  task :download do
    on roles(:all) do
      execute :sudo, :cp, "#{NGINX_PATH}/#{CONF_FILE}", "#{$HOME}/#{CONF_FILE}.prod"
      download("#{$HOME}/#{CONF_FILE}.prod", LOCAL_CONF_DIRECTORY)
      end
    end
  end
end

namespace :nginx do
  desc 'Restart the nginx server'
  task :rstart do
    on roles(:all) do
      execute :sudo, :service, :nginx, :restart
    end
  end
end