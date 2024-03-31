namespace :db do
    desc "Verify database credentials"
    task :verify  => :environment do
        app_dir = "/var/www/rendezvous/current"
        shared_dir = "#{app_dir}/shared"
        db_config_file = "#{shared_dir}/config/database.yml"

        db_config = YAML.load_file(db_config_file)[rails_env]

        puts db_config
    end
end
