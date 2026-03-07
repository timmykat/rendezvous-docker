# Tips and Tricks
## Building the Gemfile.lock
```
docker compose run rails_app bundle
docker compose up --build
```
(from https://stackoverflow.com/questions/37927978/how-do-i-update-gemfile-lock-on-my-docker-host)

## Production Deploy
The site is hosted by a Hostinger VPS

| Shortcut | Expanded command |
|---|---|
| $ ssh rdvh | (excluded for security) |
| $ cd $PROD | cd /var/www/rendezvous-docker-prod |
| $ git pull | -- |
| # Rebuild the container |
| $ docker-compose build --no-cache | docker compose -f production-compose.yml build --no-cache |
| # Perform migrations |
| $ appexec rake db:migrate | docker exec rails_app_prod -it rake db:migrate |
| # Precompile new assets |
| $ precompile | docker exec rails_app_prod -it rake db:assets:precompile |