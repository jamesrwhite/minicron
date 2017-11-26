FROM ruby:2.4.1

MAINTAINER James White <james.white@minicron.com>
LABEL maintainer="james.white@minicron.com"

WORKDIR /usr/src/app

# Install required packages
RUN apt-get update && apt-get install -y less

# Run core setup
RUN gem install --version 1.15.4 bundler

# Copy over the dependency files
COPY Gemfile /usr/src/app
COPY Gemfile.lock /usr/src/app
COPY minicron.gemspec /usr/src/app

# Install dependencies
RUN bundle install

# Copy the app over and switch into that dir
COPY . /usr/src/app

EXPOSE 9292

ENTRYPOINT ["bundle", "exec", "bin/minicron-server"]
CMD ["server", "--debug"]
