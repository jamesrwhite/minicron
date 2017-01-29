.PHONY: build

build:
	bundle
	rake build
	rake clean

install:
	rake install:local
