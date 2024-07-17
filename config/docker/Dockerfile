FROM ruby:3.2.2 as main

RUN apt-get update -qq 
RUN apt-get -y -qq install nodejs npm

RUN npm install yarn --global

ENV RAILS_ROOT /var/www/rendezvous
RUN mkdir -p $RAILS_ROOT 

WORKDIR $RAILS_ROOT

# Add gem setup
RUN gem install bundler

COPY Gemfile Gemfile.lock ./

RUN bundle install

# Add project files and precompile assets
COPY . .

RUN yarn install

EXPOSE 3000 

