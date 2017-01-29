.PHONY: build

deps:
	gem install bundler

build: deps
	bundle
	rake build
	rake clean

install: deps build
	rake install

test: deps
	bundle exec rspec
