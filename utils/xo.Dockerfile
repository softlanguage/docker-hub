# docker build --network host --force-rm -f xo.Dockerfile -t softlang/devops:go-xo .
# build image
FROM golang:alpine3.16 AS builder

# install build tools
RUN apk update && apk upgrade && \
    apk add --no-cache git gcc musl-dev

RUN go env -w GO111MODULE=on \
	&& go env -w GOPROXY=https://goproxy.cn,direct \
	&& go install github.com/xo/xo@latest

FROM alpine:3.16

COPY --from=builder /go/bin/xo /usr/bin/xo

CMD [ "nc", "-l", "-p", "80" ]

# docker build --force-rm -f xo.Dockerfile -t softlang/devops:go-xo .
# docker run -itd --rm --name xo -p 8080:80 softlang/devops:go-xo 
