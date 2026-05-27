#!/bin/sh
# MySQL backup script — chạy bằng cron trên server hoặc thêm vào docker-compose như một service.
# Ví dụ cron: 0 2 * * * /opt/quyen-auto/scripts/backup-mysql.sh
#
# Yêu cầu: biến môi trường DB_ROOT_PASSWORD, DB_NAME phải được set
# (source file .env.production hoặc export thủ công trước khi chạy)

set -e

BACKUP_DIR="${BACKUP_DIR:-/var/backups/quyen-auto}"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
FILENAME="$BACKUP_DIR/mysql_${DB_NAME}_${TIMESTAMP}.sql.gz"
KEEP_DAYS="${KEEP_DAYS:-7}"

mkdir -p "$BACKUP_DIR"

docker exec quyen-auto-mysql \
  mysqldump -u root -p"${DB_ROOT_PASSWORD}" \
  --single-transaction --quick --lock-tables=false \
  "${DB_NAME}" | gzip > "$FILENAME"

echo "Backup saved: $FILENAME"

# Xóa backup cũ hơn KEEP_DAYS ngày
find "$BACKUP_DIR" -name "mysql_*.sql.gz" -mtime +${KEEP_DAYS} -delete
echo "Cleaned up backups older than ${KEEP_DAYS} days"
