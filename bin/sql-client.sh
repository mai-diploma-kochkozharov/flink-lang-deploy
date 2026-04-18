#!/usr/bin/env bash
# ============================================================
#  sql-client.sh — открыть интерактивный Flink SQL Client
#
#  Подключается к SQL Gateway на JM-хосте (поднимается через
#  playbooks/start.yml).
#
#  Использование:
#    ./bin/sql-client.sh
# ============================================================
set -euo pipefail

JM_HOST="${JM_HOST:-lang34.delta.sbrf.ru}"
GATEWAY_PORT="${GATEWAY_PORT:-8083}"
FLINK_HOME="${FLINK_HOME:-/opt/flink-ivkochkozharov/flink-2.2.0}"
SSH_USER="${SSH_USER:-$USER}"

echo "==> Проверяю SQL Gateway на ${JM_HOST}:${GATEWAY_PORT} ..."
if ! curl -sf "http://${JM_HOST}:${GATEWAY_PORT}/v1/info" >/dev/null; then
  echo "ERROR: SQL Gateway недоступен на ${JM_HOST}:${GATEWAY_PORT}"
  echo "Запусти кластер: ansible-playbook playbooks/start.yml"
  exit 1
fi

echo "==> Подключаюсь к SQL Client (выход: QUIT;  или Ctrl+D)"
exec ssh -t "${SSH_USER}@${JM_HOST}" \
  "export FLINK_HOME=${FLINK_HOME} && \
   export HADOOP_CLASSPATH=\$(hadoop classpath) && \
   \${FLINK_HOME}/bin/sql-client.sh gateway \
     --endpoint ${JM_HOST}:${GATEWAY_PORT}"
