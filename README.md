# Tips and Tricks
## Building the Gemfile.lock
```
docker compose run rails_app bundle
docker compose up --build
```
(from https://stackoverflow.com/questions/37927978/how-do-i-update-gemfile-lock-on-my-docker-host)