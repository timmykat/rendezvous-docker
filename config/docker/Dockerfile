FROM ruby:3.1.2 as main

RUN apt-get update

RUN apt install -yq nodejs npm

RUN npm install yarn --global

COPY ./../../rendezvous_app /app

WORKDIR /app

RUN gem install bundler

RUN bundle install

RUN yarn install

EXPOSE 3000 

