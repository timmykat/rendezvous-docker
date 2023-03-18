namespace :maintenance do

  desc 'Maintenance mode on'
  task :on do
    on roles(:all) do
      within release_path do
        execute :ln, '-s', '/var/www/rendezvous/shared/public/maintenance.html', 'public/maintenance.html'
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
end
