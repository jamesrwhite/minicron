.PHONY: build

deps:
	gem install bundler

build:
	bundle
	rake build
	rake clean

install:
	rake install

test:
	bundle exec rspec
