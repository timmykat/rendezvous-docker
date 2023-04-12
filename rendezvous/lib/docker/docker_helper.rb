module Rendezvous
  module Docker
    def docker_env?
      Dir.exists? '/proc/docker'
    end
  end
end