#
# These commands assume a working environment is installed locally
# or this is running in docker
#

setup:
	gem install --version 1.15.4 bundler

build:
	bundle install

test:
	bundle exec rspec

run:
	bundle exec bin/minicron-server --debug --verbose
