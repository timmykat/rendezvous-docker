namespace :puma do

  desc 'Stop the puma process'
  task :stop do
    on roles(:all) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :sudo, :service, :puma, :stop
        end
      end
    end
  end

  desc 'Start the puma process'
  task :start do
    on roles(:all) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :sudo, :service, :puma, :start
        end
      end
    end
  end

  desc 'Restart the puma process'
  task :restart do
    on roles(:all) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :sudo, :service, :puma, :restart
        end
      end
    end
  end

end
