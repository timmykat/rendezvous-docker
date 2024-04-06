# citroenrendezvous.org README

This is the repo containing the rails application which runs the citroenrendezvous.org website, including event registration.
The rails application itself is in the `rendezvous` folder and `bundle exec` commands must be run from there 

_10 March 2024_

## Development
Developing for the application requires:
- docker

Docker images:
- ruby:3.2.2 
- mysql:8.0.32
- nginx (latest should be fine)

### config/docker/Dockerfile 
- Pulls the ruby image
- Installs `yarn`
- Installs `bundler`
- Runs `bundle install` from Gemfile.lock
- runs `yarn install`

Rails version: 7.0.4
Application server: puma
Database: mysql (mysql2 gem)

### Setup
- Install docker if you don't already have it.
- In the root directory:
```
$ docker compose build
$ docker compose up
```
This will start containers:
- `rendezvous-docker-rails_app-1`
- `rendezvous-docker-nginx-1`
- `rendezvous-docker-mysql-1`
~Another container,`rendezvous-docker-delayed_job-1` which handles email sends, will start if you add --profile=full~

The development site runs in the `production` environment so you will want to precompile assets:
`docker exec -it rendezvous-docker-rails_app-1 bundle exec rake assets:precompile

## Production
### Amazon Web Services (AWS)
The website runs on Amazon AWS infrastructure in Tim Kinnel's AWS account.
Services:
- EC2 for the web server, using and Amazon Linux 2023 AMI
- RDS for the database
- SES for email handling, including login links
- IAM for permissions management

### DNS
DNS is handled through Tim's account at hover.commands

### SSL certificates
SSL certs can be obtained from a number of sources. This has been my choice:
- namecheap.com
- EssentialSSL certificates




