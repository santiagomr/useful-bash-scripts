#!/bin/bash

### @santiagomr
### GNU GPL v3.0

APP_PATH=/var/www/nextcloud
APP_NAME=nextcloud

BKP_PATH=/var/backups
LOG_PATH=/var/log/nextcloud_backup.log

DB_TYPE=mysql 		# mysql - pgsql - sqlite
DB_HOST=localhost
DB_NAME=db_name
DB_USER=db_user
DB_PASS=db_pass


echo "$(date -R) *** STARTING BACKUP" >> $LOG_PATH

# Turn on maintenance mode to avoid inconsistencies in your data
sudo -u www-data php $APP_PATH/occ maintenance:mode --on >> $LOG_PATH

echo "$(date -R) *** Backing up app files" >> $LOG_PATH
rsync -Aavx $APP_PATH/ $BKP_PATH/$APP_NAME.$(date +%Y%m%d)/

echo "$(date -R) *** Backing up app database" >> $LOG_PATH
if [ "$DB_TYPE" == "mysql" ]
then
  mysqldump --single-transaction -h $DB_HOST -u $DB_USER -p$DB_PASS $DB_NAME > $BKP_PATH/$DB_NAME.sqlbkp.$(date +%Y%m%d).bak

elif [ "$DB_TYPE" == "pgsql" ]
then
  PGPASSWORD="$DB_PASS" pg_dump $DB_NAME -h $DB_HOST -U $DB_USER -f $BKP_PATH/$DB_NAME.sqlbkp.$(date +%Y%m%d).bak

elif [ "$DB_TYPE" == "sqlite" ]
then
  sqlite3 $APP_PATH/data/owncloud.db .dump > $BKP_PATH/$DB_NAME.sqlbkp.$(date +%Y%m%d).bak

else
  echo "$(date -R) *** ERROR: DB_TYPE isn't valid" >> $LOG_PATH
	echo -e "\n    ERROR: The indicated DB_TYPE isn't valid"
  echo -e "  The possible choices are: mysql, pgsql, sqlite \n"
fi

# Turn off maintenance mode
sudo -u www-data php $APP_PATH/occ maintenance:mode --off >> $LOG_PATH

echo "$(date -R) *** BACKUP FINISHED" >> $LOG_PATH
