namespace :puma do

  desc 'Stop the puma process'
  task :stop do
    on roles(:all) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :sudo, :systemctl, :stop, :puma
        end
      end
    end
  end

  desc 'Start the puma process'
  task :start do
    on roles(:all) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :sudo, :systemctl, :start, :puma
        end
      end
    end
  end

  desc 'Restart the puma process'
  task :restart do
    on roles(:all) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :sudo, :systemctl, :restart, :puma
        end
      end
    end
  end

end
