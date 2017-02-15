.PHONY: build

deps:
	gem install bundler

build_assets:
	RACK_ENV=production rake assets:precompile

build:
	bundle
	make build_assets
	rake build

install:
	rake clobber
	make build
	gem install pkg/*.gem

test:
	bundle exec rspec
