FROM phusion/baseimage:0.9.16
MAINTAINER James White <dev.jameswhite+minicron@gmail.com>

# Install Ruby and minicron build dependencies
RUN apt-get update && apt-get install -y \
  libsqlite3-dev \
  wget \
  unzip

# Get the latest minicron release
RUN wget https://github.com/jamesrwhite/minicron/releases/download/v0.9.0/minicron-0.9.0-linux-x86_64.zip
RUN unzip -o minicron-0.9.0-linux-x86_64.zip

# Add minicron folder to $PATH
ENV PATH=/minicron-0.9.0-linux-x86_64:$PATH

# Expose minicron on port 9292
EXPOSE 9292
