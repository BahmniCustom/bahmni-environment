#!/bin/bash
set -e -x

BACKUP_PATH='/backup'
echo "Attempting to create backup folder: $BACKUP_PATH"
sudo mkdir -pv $BACKUP_PATH

# Perform backup of MYSQL DB
TIME=`date +%Y%m%d_%H%M%S`
$BACKUP_PATH="$BACKUP_PATH/backup_$TIME"
sudo mysqldump -uroot -ppassword --all-databases --routines | gzip > $BACKUP_PATH/mysql_backup_$TIME.sql.gz

sudo chown postgres:postgres $BACKUP_PATH

# Perform backup of PostgreSQL DB
su - postgres -c "pg_dumpall | gzip -c > $BACKUP_PATH/pgsql_backup_$TIME.sql.gz"

echo ">> Backups created at: $BACKUP_PATH"
