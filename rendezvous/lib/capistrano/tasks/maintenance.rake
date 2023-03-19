namespace :rendezvous do
  namespace :maintenance do

    desc 'Maintenance mode on'
    task :on do
      on roles(:all) do
        within release_path do
          execute :ln, '-s', '/var/www/rendezvous/shared/public/maintenance.html', '/var/www/rendezvous/current/public/maintenance.html'
        end
      end
    end

    desc 'Maintenance mode off'
    task :off do
      on roles(:all) do
        within release_path do
          execute :rm, 'public/maintenance.html'
        end
      end
    end

    desc 'Maintenance status'
    task :status do
      on roles(:all) do
        within release_path do
          status = capture(execute :ls, 'public/maintenance.html')
          if (status == 0)
            state = "ON"
          else
            state= "OFF"
          end
          puts "\n** Maintenance mode is #{state} **\n\n"
        end
      end
    end
  end
end
