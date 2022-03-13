#!/usr/bin/env sh

# Exit on errors.
set -o errexit
set -o pipefail

# Set some defaults.
BACKUP_ENABLED="${BACKUP_ENABLED:-true}"
BACKUP_DIR="${BACKUP_DIR:-saves/backups}"
BACKUP_RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-30}"

SERVER_NAME="${SERVER_NAME:-Valheim Server}"
SERVER_PORT="${SERVER_PORT:-2456}"
SERVER_PUBLIC="${SERVER_PUBLIC:-0}"
SERVER_WORLD_NAME="${SERVER_WORLD_NAME:-world}"

# Send quit signal and wait for the server to terminate.
_quit_server() {
  # Server not started yet.
  if [ -z ${child} ]; then
    return
  fi
  kill -SIGINT "${child}"
  wait "${child}"
}

# Signal handlers.
_term() {
  echo "--> Caught SIGTERM signal!"
  _quit_server  
}
_int() {
  echo "--> Caught SIGINT signal!"
  _quit_server  
}

# Trap quit signals.
trap _term SIGTERM
trap _int SIGINT

# Create a backup of the world.
backup() {
  NOW=$(date +"%Y%m%d_%H%M%S")
  BACKUP_FILE="${BACKUP_DIR}/${SERVER_WORLD_NAME}_${NOW}.tar.gz"
  echo "==> Backing up the server to ${BACKUP_FILE} ...";
  mkdir -p "${BACKUP_DIR}"
  tar czvf "${BACKUP_FILE}" "saves/worlds/${SERVER_WORLD_NAME}".*
  echo "==> ...backup completed.";
}

# Cleanup oldest backups of the world.
cleanup() {
  echo "==> Cleaning oldest backups...";
  find "${BACKUP_DIR}" -type f -name "*.tar.gz" -mtime "+${BACKUP_RETENTION_DAYS}" -print -delete
  echo "==> ...cleanup completed.";
}

# Start the server.
echo "==> Starting valheim server...";
exec ./valheim_server.x86_64 \
  -name ${SERVER_NAME} \
  -port ${SERVER_PORT} \
  -savedir saves \
  -world ${SERVER_WORLD_NAME} \
  -password ${SERVER_PASSWORD} \
  -public ${SERVER_PUBLIC} &

child=$!
wait "${child}" || echo "==> Server returned with ${?}"
echo "==> valheim server stopped.";

# Backup and cleanup if required.
if [[ ${BACKUP_ENABLED} == "true" ]]; then
  backup
  if [[ ${BACKUP_RETENTION_DAYS} -gt 0 ]]; then
    cleanup
  fi
fi

echo "==> Exiting."