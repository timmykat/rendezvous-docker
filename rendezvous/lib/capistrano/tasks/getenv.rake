desc "Show remote environment"
task :getenv do
    on roles(:all) do
      remote_env = capture("env")
      puts remote_env
    end
end