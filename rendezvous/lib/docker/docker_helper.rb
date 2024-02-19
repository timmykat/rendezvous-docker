module Rendezvous
  module Docker
    def docker_env?
      Dir.exist? '/proc/docker'
    end
  end
end