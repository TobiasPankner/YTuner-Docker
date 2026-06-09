FROM alpine:3.19

LABEL org.opencontainers.image.title="YTuner"
LABEL org.opencontainers.image.description="Self hosted vTuner internet radio service emulation"
LABEL org.opencontainers.image.url="https://github.com/coffeegreg/YTuner"
LABEL org.opencontainers.image.source="https://github.com/TobiasPankner/YTuner-Docker"
LABEL org.opencontainers.image.licenses="MIT"

ARG VERSION=1.2.2

RUN apk --no-cache add libc6-compat sqlite-libs wget unzip

ARG TARGETARCH
RUN case "${TARGETARCH}" in \
      amd64)  ARCH="x86_64-linux" ;; \
      arm64)  ARCH="aarch64-linux" ;; \
      arm/v7) ARCH="arm-linux" ;; \
      *)      echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
    esac && \
    wget -q "https://github.com/coffeegreg/YTuner/releases/download/${VERSION}/ytuner-${VERSION}-${ARCH}.zip" && \
    unzip -o "ytuner-${VERSION}-${ARCH}.zip" ytuner ytuner.ini -d /app/ && \
    rm "ytuner-${VERSION}-${ARCH}.zip" && \
    chmod +x /app/ytuner && \
    apk del wget unzip

WORKDIR /app

EXPOSE 80/tcp
EXPOSE 53/udp

VOLUME /app/host-shared

CMD ["./ytuner"]
