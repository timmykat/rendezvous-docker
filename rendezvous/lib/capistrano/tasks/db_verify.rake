namespace :db do
    desc "Verify the remote database credentials"
    task :verify do
        with rails_env: fetch(:rails_env) do
            execute :bundle, :exec, :'rake', 'db:verify'
        end
    end
end