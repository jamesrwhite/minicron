FROM phusion/baseimage:0.9.16
MAINTAINER James White <dev.jameswhite+minicron@gmail.com>

# Install minicron install dependencies
RUN apt-get update && apt-get install -y curl unzip

# Install minicron
ADD install.sh /
RUN chmod +x /install.sh
RUN /install.sh
