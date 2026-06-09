FROM debian:bookworm-slim AS downloader

ARG VERSION=1.2.6
ARG TARGETARCH

RUN apt-get update && \
    apt-get install -y --no-install-recommends wget unzip ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN ARCH="${TARGETARCH}" && \
    if [ -z "${ARCH}" ]; then ARCH=$(uname -m); fi && \
    case "${ARCH}" in \
      amd64|x86_64)    YTARCH="x86_64-linux" ;; \
      arm64|aarch64)   YTARCH="aarch64-linux" ;; \
      *)               echo "Unsupported architecture: ${ARCH}" && exit 1 ;; \
    esac && \
    wget -q "https://github.com/coffeegreg/YTuner/releases/download/${VERSION}/ytuner-${VERSION}-${YTARCH}.zip" && \
    mkdir -p /app && \
    unzip -o "ytuner-${VERSION}-${YTARCH}.zip" -d /tmp/ytuner-extract/ && \
    cp /tmp/ytuner-extract/*/ytuner /app/ytuner 2>/dev/null || cp /tmp/ytuner-extract/ytuner /app/ytuner && \
    cp /tmp/ytuner-extract/*/ytuner.ini /app/ytuner.ini 2>/dev/null || cp /tmp/ytuner-extract/ytuner.ini /app/ytuner.ini && \
    rm -rf "ytuner-${VERSION}-${YTARCH}.zip" /tmp/ytuner-extract && \
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
