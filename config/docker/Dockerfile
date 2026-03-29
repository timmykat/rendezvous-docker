FROM ruby:3.4.2 as main

RUN apt-get update -qq && \
    apt-get install -y curl xz-utils nodejs npm

# Install yarn (no nvm needed)
RUN npm install -g yarn

ENV RAILS_ROOT=/var/www/rendezvous
RUN mkdir -p $RAILS_ROOT

WORKDIR $RAILS_ROOT

# Install bundler + gems first (better caching)
RUN gem install bundler

COPY Gemfile Gemfile.lock ./
RUN bundle install

# Add project files
COPY . .

# Install JS deps
RUN yarn install --frozen-lockfile

# 🔥 THIS is what you’re missing
RUN bundle exec rake assets:precompile

EXPOSE 3000
