FROM ubuntu:14.04
MAINTAINER James White <dev.jameswhite+minicron@gmail.com>

# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl

# Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

# Make sure everything is up to date
RUN apt-get update
RUN apt-get -y upgrade

# Install Ruby and minicron build dependencies
RUN apt-get install -y ruby libsqlite3-dev ruby-dev build-essential less

# Install minicron
RUN gem install --no-ri --no-rdoc minicron

# Set up the sqlite database
RUN minicron db setup

# Expose minicron on port 9292
EXPOSE 9292
