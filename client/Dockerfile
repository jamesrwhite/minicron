FROM golang:1.10.2

LABEL maintainer="james.white@minicron.com"

WORKDIR /go/src/github.com/jamesrwhite/minicron/client

COPY . .

ARG GOOS=linux
ARG GOARCH=amd64

RUN GOOS=${GOOS} GOARCH=${GOARCH} go build -o minicron .
RUN cp ./minicron /usr/local/bin/minicron
