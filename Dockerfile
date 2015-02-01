FROM phusion/baseimage:0.9.16
MAINTAINER James White <dev.jameswhite+minicron@gmail.com>

# Install Ruby and minicron build dependencies
RUN apt-get install -y ruby libsqlite3-dev ruby-dev build-essential less

# Install minicron
RUN gem install --no-ri --no-rdoc minicron

# Set up the sqlite database
RUN minicron db setup

# Expose minicron on port 9292
EXPOSE 9292
