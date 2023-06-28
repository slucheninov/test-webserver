FROM --platform=linux/amd64 golang:1.20.3-alpine3.16 as builder
WORKDIR /app

COPY main.go main.go
COPY go.mod go.mod

RUN go get -d -v

ARG BUILD_OPTS='-i' 
RUN go build ${BUILD_OPT} -o webserver main.go

FROM --platform=linux/amd64 alpine:3.16

RUN apk update && apk add ca-certificates && apk add bash

COPY --from=builder /app/webserver /usr/local/bin/webserver
