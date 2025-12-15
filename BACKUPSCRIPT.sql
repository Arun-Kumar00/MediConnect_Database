#!/bin/bash

# Backup configuration
BACKUP_DIR="/home/backups/SWHDIS"
DB_NAME="wound_healing_db"
DB_USER="root"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_$TIMESTAMP.sql"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Perform backup
echo "Starting backup of $DB_NAME..."

# NOTE: -p must not be separated from the password prompt
# If password is required, remove the space (-p)
mysqldump -u "$DB_USER" -p "$DB_NAME" > "$BACKUP_FILE"

# Check if dump succeeded
if [ $? -ne 0 ]; then
    echo "Backup failed! mysqldump returned an error."
    exit 1
fi

# Compress backup
gzip "$BACKUP_FILE"

echo "Backup completed: ${BACKUP_FILE}.gz"

# Keep only last 7 backups safely
BACKUP_COUNT=$(ls -1 "$BACKUP_DIR"/*.sql.gz 2>/dev/null | wc -l)

if [ "$BACKUP_COUNT" -gt 7 ]; then
    ls -t "$BACKUP_DIR"/*.sql.gz | tail -n +8 | xargs rm -f
    echo "Old backups cleaned up. Keeping last 7 backups."
else
    echo "Less than 7 backups exist. No cleanup required."
fi
