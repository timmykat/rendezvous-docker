HOME_DIR=/home/webuser
source "$HOME_DIR/.backup_env"
echo "Backup user:  $MYSQL_BACKUP_USER"
CONTAINER_ID=$(docker ps --filter "name=db_prod" --format "{{.ID}}")
echo "Container ID: $CONTAINER_ID"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
mkdir -p "$HOME_DIR/backup"
BACKUP_FILE="$HOME_DIR/backup/backup-TIMESTAMP.sql"
docker exec "$CONTAINER_ID" mysqldump -u "$MYSQL_BACKUP_USER" -p "$MYSQL_BACKUP_PASSWORD" "$MYSQL_DATABASE" > "$BACKUP_FILE"
gzip "$BACKUP_FILE"