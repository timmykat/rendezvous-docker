
namespace :maintenance do

  MAINTENANCE_SIGNAL = '/var/www/rendezvous/shared/public/files/show_maintenance.txt'

  desc 'Maintenance mode on'
  task :on do
    on roles(:all) do
      within release_path do
        execute :touch, MAINTENANCE_SIGNAL
      end
    end
  end

  desc 'Maintenance mode off'
  task :off do
    on roles(:all) do
      within release_path do
        execute :rm, MAINTENANCE_SIGNAL
      end
    end
  end

  desc 'Maintenance status'
  task :status do
    on roles(:all) do
      within release_path do
        status = capture %([ -f #{MAINTENANCE_SIGNAL}]), raise_on_non_zero_exit: false
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

