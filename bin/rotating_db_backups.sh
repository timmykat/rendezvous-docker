#!/bin/bash

# Configuration
CONTAINER_ID=$(docker ps --filter "name=db_prod" --format "{{.ID}}")
if [ -z "$CONTAINER_ID" ]; then
    echo "Error: Container 'rails_app_prod' not found or not running."
    exit 1
fi
DB_NAME="rendezvous"
BACKUP_ROOT="/var/backups/rendezvous"  # Change to your desired backup location
MAX_BACKUPS=7  # Number of backups to keep
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
DATE=$(date +"%Y-%m-%d)

mkdir -p "$BACKUP_ROOT/daily" "$BACKUP_ROOT/weekly" "$BACKUP_ROOT/monthly"

# Perform the backup
BACKUP_FILE="$BACKUP_ROOT/daily/db-backup-$TIMESTAMP.sql"
BACKUP_FILE_GZ="$BACKUP_FILE.gz"
docker exec "$CONTAINER_ID" mysqldump -u "$MYSQL_USER" -p "$MYSQL_PASSWORD" "$DB_NAME" > "$BACKUP_FILE"

# Compress the backup
gzip "$BACKUP_FILE"
FILE_SIZE=$(ls -l $BACKUP_FILE_GZ | awk '{print $5/1024 " k"}')
echo -e "Backup run completed.\n\n Backup file: $BACKUP_FILE_GZ\nFile size: $FILE_SIZE" | mail -s "Rendezvous backup notification $DATE" -r "Rendezvous Backups <info@citroenrendezvous.org>" kinnel@warpmail.net

# Determine backup type
DAY_OF_WEEK=$(date +%u)  # 1 = Monday, 7 = Sunday
DAY_OF_MONTH=$(date +%d)

# If it's Sunday, keep as a weekly backup
if [ "$DAY_OF_WEEK" -eq 7 ]; then
    cp "$BACKUP_ROOT/daily/db-backup-$TIMESTAMP.sql.gz" "$BACKUP_ROOT/weekly/db-backup-$TIMESTAMP.sql.gz"
fi

# If it's the 1st of the month, keep as a monthly backup
if [ "$DAY_OF_MONTH" -eq 1 ]; then
    cp "$BACKUP_ROOT/daily/db-backup-$TIMESTAMP.sql.gz" "$BACKUP_ROOT/monthly/db-backup-$TIMESTAMP.sql.gz"
fi

# Cleanup: Delete daily backups older than 7 days
find "$BACKUP_ROOT/daily" -type f -name "*.sql.gz" -mtime +7 -delete

# Cleanup: Delete weekly backups older than 4 weeks
find "$BACKUP_ROOT/weekly" -type f -name "*.sql.gz" -mtime +30 -delete

# Cleanup: Delete monthly backups older than 6 months
find "$BACKUP_ROOT/monthly" -type f -name "*.sql.gz" -mtime +180 -delete

# Log completion
echo "Backup completed: $BACKUP_FILE.gz"