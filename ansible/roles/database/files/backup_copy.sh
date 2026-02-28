#!/usr/bin/env bash

# Путь к папке с бэкапами
BACKUP_DIR="/home/ansible/backups"
DATE=$(date +"%Y%m%d_%H%M")

# Создаём папку, если её нет
mkdir -p "$BACKUP_DIR"

# Путь к архиву
BACKUP_FILE="$BACKUP_DIR/postgres_$DATE.sql"

# Выполняем бэкап всех баз и ролей
if pg_dumpall --clean --if-exists --file="$BACKUP_FILE" --username=postgres; then
  # Сжимаем бэкап
  gzip "$BACKUP_FILE"
  echo "Backup created and compressed: $BACKUP_FILE.gz"
  exit 0
else
  echo "Backup failed!" >&2
  exit 1
fi