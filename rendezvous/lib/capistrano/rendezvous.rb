module Capistrano
  class Rendezvous < Capistrano::Plugin 
    def define_tasks
      puts File.expand_path('../tasks/maintenance.rake', __FILE__)
      eval_rakefile File.expand_path('../tasks/maintenance.rake', __FILE__)
    end
  end
end
