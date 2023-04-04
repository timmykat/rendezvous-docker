
namespace :maintenance do

  SHARED = "/var/www/rendezvous/shared/public/files/maintenance.html"
  CURRENT = "/var/www/rendezvous/current/public/files/maintenance.html"

  desc 'Maintenance mode on'
  task :on do
    on roles(:all) do
      within release_path do
        execute :ln, '-s', SHARED, CURRENT 
      end
    end
  end

  desc 'Maintenance mode off'
  task :off do
    on roles(:all) do
      within release_path do
        execute :rm, CURRENT
      end
    end
  end

  desc 'Maintenance status'
  task :status do
    on roles(:all) do
      within release_path do
        status = capture %([ -f #{CURRENT}]), raise_on_non_zero_exit: false
        if (status)
          state = "ON"
        else
          state= "OFF"
        end
        puts "\n** Maintenance mode is #{state} **\n\n"
      end
    end
  end
end

