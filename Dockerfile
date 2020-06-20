FROM golang:1.13-alpine as builder

WORKDIR /home

ENV GOPATH /go
ENV CGO_ENABLED 0
ENV GO111MODULE on

RUN  \
     apk add --no-cache git 'curl>7.61.0' && \
     git clone https://github.com/minio/minio && \
     curl -L https://github.com/balena-io/qemu/releases/download/v3.0.0%2Bresin/qemu-3.0.0+resin-arm.tar.gz | tar zxvf - -C . && mv qemu-3.0.0+resin-arm/qemu-arm-static .

FROM arm64v8/alpine:3.12

COPY --from=builder /home/qemu-arm-static /usr/bin/qemu-arm-static
COPY docker-entrypoint.sh /usr/bin/docker-entrypoint.sh

ENV MINIO_UPDATE off
ENV MINIO_ACCESS_KEY=access_key \
    MINIO_SECRET_KEY=secret_key \
    MINIO_ACCESS_KEY_FILE=access_key \
    MINIO_SECRET_KEY_FILE=secret_key \
    MINIO_KMS_MASTER_KEY_FILE=kms_master_key \
    MINIO_SSE_MASTER_KEY_FILE=sse_master_key

RUN apk add --no-cache ca-certificates 'curl>7.61.0' 'su-exec>=0.2'

RUN echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf

RUN curl --silent --show-error --fail --location \
	--header "Accept: application/tar+gzip, application/x-gzip, application/octet-stream" -o /usr/bin/minio \
	"https://dl.minio.io/server/minio/release/linux-arm64/minio" \
	&& chmod 0755 /usr/bin/minio \
	&& chmod +x /usr/bin/docker-entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]

VOLUME ["/data"]

CMD ["minio"]
