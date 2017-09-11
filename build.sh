#!/bin/sh

# Client build
echo "TODO: add client build"

# Server build
cd server
make setup
make build
make test
