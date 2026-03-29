FROM ruby:3.4.2 AS main

RUN apt-get update -qq && \
    apt-get install -y curl xz-utils nodejs npm default-mysql-client

# Install yarn (no nvm needed)
RUN npm install -g yarn

ARG RAILS_ENV=production
ARG NODE_ENV=production

ENV RAILS_ENV=$RAILS_ENV
ENV NODE_ENV=$NODE_ENV

ENV RAILS_ROOT=/var/www/rendezvous
ENV REDIS_URL=redis://redis:6379/0

RUN echo "RAILS_ENV=$RAILS_ENV NODE_ENV=$NODE_ENV"

RUN mkdir -p $RAILS_ROOT

WORKDIR $RAILS_ROOT

# Install bundler + gems first (better caching)
RUN gem install bundler

# ---- Ruby deps layer ----
COPY Gemfile Gemfile.lock ./
RUN bundle install

# ---- JS deps layer ----
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# ---- App code ----
COPY . .

# 🔥 THIS is what you’re missing
RUN bundle exec rake assets:precompile

EXPOSE 3000
