#!/bin/bash

# Check if database variables are present
if [ -z "$MARIADB_HOST" ] || [ -z "$MARIADB_USER" ] || [ -z "$MARIADB_PASSWORD" ] || [ -z "$MARIADB_DATABASE" ]; then
    echo 'Database environment variables missing!'
    exit 1
fi

# Timestamp for the backup file
TIMESTAMP=$(date +"%Y-%m-%d-%H-%M")
BACKUP=''

BACKUP="${MARIADB_DATABASE}_${TIMESTAMP}.sql"
echo "Dumping database '$MARIADB_DATABASE' from '$MARIADB_HOST'"
if ! mysqldump -h "$MARIADB_HOST" -u "$MARIADB_USER" -p"$MARIADB_PASSWORD" "$MARIADB_DATABASE" > "$BACKUP"; then
    echo "Error: Failed to dump database '$MARIADB_DATABASE'!"
    exit 1
fi

echo "Compressing '$BACKUP' to '${BACKUP}.tar.gz'"
if ! tar -zcvf "${BACKUP}.tar.gz" $BACKUP ; then
    echo "Error: Failed to compress '$BACKUP'!"
    exit 1
fi

mv "${BACKUP}.tar.gz" /nfsmount
echo 'Backup completed'
