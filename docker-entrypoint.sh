#!/bin/sh
set -e
if [ -f /app/host-shared/ytuner.ini ]; then
    cp /app/host-shared/ytuner.ini /app/ytuner.ini
fi
sed -i 's|^CacheFolderLocation=.*|CacheFolderLocation=/app/host-shared|' /app/ytuner.ini
sed -i 's|^ConfigFolderLocation=.*|ConfigFolderLocation=/app/host-shared|' /app/ytuner.ini
sed -i 's|^DBFolderLocation=.*|DBFolderLocation=/app/host-shared|' /app/ytuner.ini
exec "$@"
