#!/bin/bash

# Check if environment variables are set
if [ -z "$MARIADB_HOST" ] || [ -z "$MARIADB_USER" ] || [ -z "$MARIADB_PASSWORD" ] || [ -z "$MARIADB_DATABASE" ] || [ -z "$BACKUP_SERVER" ] || [ -z "$BACKUP_USER" ] || [ -z "$BACKUP_PATH" ]; then
    echo 'Error: Environment variables are missing. Please review configuration'
    exit 1
fi

# Timestamp for the dump file
TIMESTAMP=$(date +"%Y%m%d%H%M")
BACKUP="${MARIADB_DATABASE}_${TIMESTAMP}.sql"
# Dump the specified database locally
echo "Dumping database '$MARIADB_DATABASE' from '$MARIADB_HOST'"
if ! mysqldump -h "$MARIADB_HOST" -u "$MARIADB_USER" -p"$MARIADB_PASSWORD" "$MARIADB_DATABASE" > "$BACKUP"; then
    echo "Error: Failed to dump database '$MARIADB_DATABASE'!"
    exit 1
fi

# Transfer the dump file to the remote file server using SCP
echo "Transferring $BACKUP to $BACKUP_SERVER"
if ! scp "$BACKUP" "$BACKUP_USER"@"$BACKUP_SERVER":"$BACKUP_PATH"; then
    echo "Error: Failed to transfer $BACKUP to $BACKUP_SERVER"
    exit 1
fi

echo 'Backup completed'
