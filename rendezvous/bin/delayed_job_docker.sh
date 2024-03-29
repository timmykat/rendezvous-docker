#!/bin/bash

cd ..

# Variable DELAYED_JOB_ARGS contains the arguments for delayed jobs for, e.g. defining queues and worker pools.

# function that is called when the docker container should stop. It stops the delayed job processes
_term() {
  echo "Caught SIGTERM signal! Stopping delayed jobs !"
  # unbind traps
  trap - SIGTERM
  trap - TERM
  trap - SIGINT
  trap - INT
  # end delayed jobs 
  bundle exec "./bin/delayed_job stop"

  exit
}

# register handler for selected signals
trap _term SIGTERM
trap _term TERM
trap _term INT
trap _term SIGINT

echo "Starting delayed jobs ... "

# restart delayed jobs on script execution
bundle exec "./bin/delayed_job ${DELAYED_JOB_ARGS} restart"

echo "Finished starting delayed jobs... Waiting for SIGTERM / CTRL C"

# sleep forever until exit
while true; do sleep 86400; done