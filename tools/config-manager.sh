#!/bin/bash
# Deprecated: use tools/backup-secrets.sh
echo "WARN: config-manager.sh 已更名为 backup-secrets.sh，请更新调用" >&2
exec "$(dirname "$0")/backup-secrets.sh" "$@"
