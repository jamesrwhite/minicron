start-gem-server:
	(cd ../minicron-build/gem-server && rm -rf data && rackup)

build:
	rm -rf pkg
	rm -f *.gem
	rm -f Gemfile.lock
	bundle
	gem build minicron.gemspec
	gem push minicron-*.gem --host http://localhost:9999
	rm -f *.gem
	(cd ../minicron-build/build && rm -rf minicron-*.tar.gz && bundle && rake package && mv minicron-*.tar.gz ../../minicron)

install:
	USE_LOCAL_TAR=1 ./install.sh
