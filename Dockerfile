FROM debian:bookworm-slim AS downloader

ARG VERSION=1.2.6
ARG TARGETARCH

RUN apt-get update && \
    apt-get install -y --no-install-recommends wget unzip ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN case "${TARGETARCH}" in \
      amd64)  ARCH="x86_64-linux" ;; \
      arm64)  ARCH="aarch64-linux" ;; \
      *)      echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
    esac && \
    wget -q "https://github.com/coffeegreg/YTuner/releases/download/${VERSION}/ytuner-${VERSION}-${ARCH}.zip" && \
    mkdir -p /app && \
    unzip -o "ytuner-${VERSION}-${ARCH}.zip" -d /tmp/ytuner-extract/ && \
    find /tmp/ytuner-extract -name ytuner -type f -exec cp {} /app/ \; && \
    find /tmp/ytuner-extract -name ytuner.ini -type f -exec cp {} /app/ \; && \
    rm -rf "ytuner-${VERSION}-${ARCH}.zip" /tmp/ytuner-extract && \
    chmod +x /app/ytuner && \
    sed -i 's|^CacheFolderLocation=.*|CacheFolderLocation=/app/host-shared|' /app/ytuner.ini && \
    sed -i 's|^ConfigFolderLocation=.*|ConfigFolderLocation=/app/host-shared|' /app/ytuner.ini && \
    sed -i 's|^DBFolderLocation=.*|DBFolderLocation=/app/host-shared|' /app/ytuner.ini

FROM debian:bookworm-slim

LABEL org.opencontainers.image.title="YTuner"
LABEL org.opencontainers.image.description="Self hosted vTuner internet radio service emulation"
LABEL org.opencontainers.image.url="https://github.com/coffeegreg/YTuner"
LABEL org.opencontainers.image.source="https://github.com/TobiasPankner/YTuner-Docker"
LABEL org.opencontainers.image.licenses="MIT"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        libsqlite3-0 \
        libssl3 && \
    rm -rf /var/lib/apt/lists/*

COPY --from=downloader /app /app
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

WORKDIR /app

EXPOSE 80/tcp

VOLUME /app/host-shared

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["./ytuner"]
