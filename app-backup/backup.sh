#!/bin/bash

# Check if environment variables are set
if [ -z "$APP_NAME" ] || [ -z "$BACKUP_SERVER" ] || [ -z "$BACKUP_USER" ] || [ -z "$BACKUP_PASS" ] || [ -z "$BACKUP_PATH" ]; then
    echo 'Error: Environment variables are missing. Please review configuration'
    exit 1
fi

# Timestamp for the backup file
TIMESTAMP=$(date +"%Y-%m-%d-%H-%M")
BACKUP="/${APP_NAME}_${TIMESTAMP}.tar.gz"
# Archive the backup locally
echo "Compressing '$APP_NAME' to '$BACKUP'"
if ! tar -zcvf $BACKUP -C /backup . ; then
    echo "Error: Failed to backup '$APP_NAME'!"
    exit 1
fi

# Transfer the dump file to the remote file server using SCP
echo "Transferring $BACKUP to $BACKUP_SERVER"
if ! sshpass -p "$BACKUP_PASS" sftp -o StrictHostKeyChecking=no "$BACKUP_USER"@"$BACKUP_SERVER" << EOF
mkdir "$BACKUP_PATH"
put "$BACKUP" "$BACKUP_PATH"
EOF
then
    echo "Error: Failed to transfer $BACKUP to $BACKUP_SERVER"
    exit 1
fi

echo 'Backup completed'
