FROM ruby:3.4.2 AS main

RUN apt-get update -qq && \
    apt-get install -y curl xz-utils nodejs npm default-mysql-client

# Install yarn (no nvm needed)
RUN npm install -g yarn

ARG RAILS_ENV=production
ARG NODE_ENV=production
ARG SECRET_KEY_BASE
ARG SKIP_ASSETS=false

ENV RAILS_ENV=$RAILS_ENV
ENV NODE_ENV=$NODE_ENV
ENV SECRET_KEY_BASE=$SECRET_KEY_BASE

ENV RAILS_ROOT=/var/www/rendezvous
ENV REDIS_URL=redis://redis:6379/0

RUN echo "RAILS_ENV=$RAILS_ENV NODE_ENV=$NODE_ENV"

RUN adduser --disabled-password --gecos '' webuser

RUN mkdir -p $RAILS_ROOT/tmp $RAILS_ROOT/storage \
    && chown -R webuser:webuser $RAILS_ROOT/tmp \
    && chown -R webuser:webuser $RAILS_ROOT/storage

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

RUN if [ "${SKIP_ASSETS}" != "true" ]; then \
      yarn build && yarn build:css && bundle exec rake assets:precompile; \
    else \
      echo "Skipping asset build"; \
    fi

EXPOSE 3000
