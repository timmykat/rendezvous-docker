#!/bin/bash
# Make staging repo 
environments=("staging" "prod")

for env in "${environments[@]}"; do

  # Setting domain
  if [ "$env" == "staging" ]; then
    domain="rendezvous-staging.wordsareimages.com"
  elif [ "$env" == "prod" ]; then
    domain="citroenrendezvous.org"
  fi

  echo "-- Making repo directory for $env"
  if [ ! -d "/var/www/rendezvous-docker-$env" ]; then
    mkdir -p /var/www/rendezvous-docker-$env
  fi

  echo "-- Setting permissions for web user"
  chown -R webuser:webuser /var/www/rendezvous-docker-$env

  echo "-- Making nginx certs directories for $env"
  if [ ! -d "/etc/nginx/ssl/certs/$domain" ]; then
    mkdir -p /etc/nginx/ssl/certs/$domain
  fi

  echo "-- Making database directories for $env"
  echo "---- /var/lib/mysql"
  if [ ! -d "/var/lib/mysql/$domain" ]; then
    mkdir -p /var/lib/mysql/$domain
  fi
  echo "---- /var/run/mysqld (pid)"
  if [ ! -d "/var/run/mysqld/$domain" ]; then
    mkdir -p /var/run/mysqld/$domain
  fi  
done

# Set up share docker network
echo "-- Setting up shared docker network"
if ! docker network ls --filter name=^shared_server_network$ --quiet; then
  echo "Network shared_server_network not found. Creating it..."
  docker network create shared_server_network
else
  echo "Network shared_server_network already exists."
fi

