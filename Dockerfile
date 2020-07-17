FROM golang:latest as golang

COPY kaniko-0.22.0.tar.gz /tmp/kaniko.tar.gz

WORKDIR /go/src/github.com/GoogleContainerTools

RUN mkdir kaniko \
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
