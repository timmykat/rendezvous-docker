FROM ruby:3.2.2 as main

RUN apt-get update -qq && \
    apt-get install -y curl xz-utils

# Install nvm and Node.js
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
ENV NVM_DIR=/root/.nvm
ENV NODE_VERSION=22.15.0
RUN bash -c "source $NVM_DIR/nvm.sh && nvm install $NODE_VERSION && nvm use $NODE_VERSION"

# Add nvm and node binaries to PATH
ENV PATH=$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# Verify Node installation
RUN node -v && npm -v

RUN npm install -g yarn

ENV RAILS_ROOT=/var/www/rendezvous
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

