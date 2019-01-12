FROM ruby:2.4.3

# Install NodeJS based on https://github.com/nodesource/distributions#installation-instructions
RUN apt-get update
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash # Installs the node repository
RUN apt-get install --yes nodejs # Actually install NODEJS

RUN mkdir /app

WORKDIR /app
ENV BUNDLE_PATH /gems

ENTRYPOINT ["./docker-entrypoint.sh"]
