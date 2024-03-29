#!/bin/bash

# Check app and type are set before logic
if [ -z "$APP_NAME" ] || [ -z "$BACKUP_TYPE" ]; then
    echo 'App/Type environment variables are missing!'
    exit 1
fi

# Check if database variables are present if set to database
if [[ "$BACKUP_TYPE" == 'database' ]]; then
    if [ -z "$MARIADB_HOST" ] || [ -z "$MARIADB_USER" ] || [ -z "$MARIADB_PASSWORD" ] || [ -z "$MARIADB_DATABASE" ]; then
        echo 'Database environment variables missing!'
        exit 1
    fi
fi

# Check if remote server variables are set
if [ -z "$BACKUP_SERVER" ] || [ -z "$BACKUP_USER" ] || [ -z "$BACKUP_PASS" ]; then
    echo 'Remote server environment variables are missing!'
    exit 1
fi

# Timestamp for the backup file
TIMESTAMP=$(date +"%Y-%m-%d-%H-%M")
BACKUP=''

if [[ "$BACKUP_TYPE" == 'database' ]]; then
    BACKUP="${MARIADB_DATABASE}_${TIMESTAMP}.sql"
    echo "Dumping database '$MARIADB_DATABASE' from '$MARIADB_HOST'"
    if ! mysqldump -h "$MARIADB_HOST" -u "$MARIADB_USER" -p"$MARIADB_PASSWORD" "$MARIADB_DATABASE" > "$BACKUP"; then
        echo "Error: Failed to dump database '$MARIADB_DATABASE'!"
        exit 1
    fi
else
    BACKUP="${APP_NAME}_${TIMESTAMP}.tar.gz"
    echo "Compressing '$APP_NAME' to '$BACKUP'"
    if ! tar -zcvf "$BACKUP" -C /backup . ; then
        echo "Error: Failed to backup '$APP_NAME'!"
        exit 1
    fi
fi

# Transfer the dump file to the remote file server using SCP
echo "Transferring $BACKUP to $BACKUP_SERVER"
if ! sshpass -p "$BACKUP_PASS" sftp -o StrictHostKeyChecking=no "$BACKUP_USER"@"$BACKUP_SERVER" << EOF
cd "$BACKUP_TYPE"
mkdir "$APP_NAME"
cd "$APP_NAME"
put "$BACKUP"
EOF
then
    echo "Error: Failed to transfer $BACKUP to $BACKUP_SERVER"
    exit 1
fi

echo 'Backup completed'
