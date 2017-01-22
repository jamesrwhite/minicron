.PHONY: build

start-gem-server:
	cd build/gem-server && rm -rf data && { rackup & echo $$! > server.pid; }

stop-gem-server:
	kill `cat build/gem-server/server.pid` || true
	rm -f build/gem-server/server.pid

build: stop-gem-server start-gem-server
	gem install bundler geminabox
	rm -rf pkg
	rm -f *.gem
	rm -f Gemfile.lock
	rm -f build/Gemfile.lock
	bundle
	gem build minicron.gemspec
	gem push minicron-*.gem --host http://localhost:9999
	rm -f *.gem
	(cd build && bundle && rm -rf minicron-*.tar.gz && rake package)
	mv build/*.tar.gz builds
	make stop-gem-server

install:
	USE_LOCAL_TAR=1 ./install.sh
