FROM elixir:alpine

# Install Npm
RUN \
    mkdir -p /opt/app && \
    chmod -R 777 /opt/app && \
    apk update && \
    apk --no-cache --update add \
      git make g++ wget curl inotify-tools \
      nodejs nodejs-npm && \
    npm install npm -g --no-progress && \
    npm install elm -g --no-progress && \
    update-ca-certificates --fresh && \
    rm -rf /var/cache/apk/*


RUN \
    mkdir -p /opt/app/web && \
    chmod -R 777 /opt/app/web && \
    cd /opt/app/web && \
    elm init && \
    elm install elm/html -y

# Add local node module binaries to PATH
ENV PATH=./node_modules/.bin:$PATH \
    MIX_HOME=/opt/mix \
    HEX_HOME=/opt/hex \
    HOME=/opt/app

# Install Hex+Rebar
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix archive.install https://github.com/phoenixframework/archives/raw/master/phx_new.ez --force

WORKDIR /opt/app