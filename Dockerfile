FROM golang:latest as golang

WORKDIR /go/src/github.com/GoogleContainerTools

RUN mkdir kaniko \
    && wget -O /tmp/kaniko.tar.gz https://github.com/GoogleContainerTools/kaniko/archive/v1.0.0.tar.gz \
    && tar -xvf /tmp/kaniko.tar.gz -C ./kaniko --strip-components 1 \
    && cd kaniko && make GOARCH=amd64

FROM alpine:latest

COPY --from=golang /go/src/github.com/GoogleContainerTools/kaniko/out/executor /kaniko/executor
COPY --from=golang /go/src/github.com/GoogleContainerTools/kaniko/files/ca-certificates.crt /kaniko/ssl/certs/

ENV TZ Asia/Shanghai
ENV SSL_CERT_DIR /kaniko/ssl/certs
ENV DOCKER_CONFIG /kaniko/.docker/

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk add --update --no-cache git bash tzdata \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && rm -rf /var/cache/apk/* && rm -rf /tmp/*

CMD ["/kaniko/executor"]
