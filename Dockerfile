FROM ruby:3.1.6

# Install NodeJS based on https://github.com/nodesource/distributions#installation-instructions
RUN apt-get update
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash # Installs the node repository
RUN apt-get install --yes nodejs # Actually install NODEJS
RUN apt-get install --yes fonts-ipafont-gothic
RUN mkdir /app

WORKDIR /app
ENV BUNDLE_PATH /gems

ENTRYPOINT ["./docker-entrypoint.sh"]
