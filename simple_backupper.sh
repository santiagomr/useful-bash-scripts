#!/bin/bash

### @santiagomr
### GNU GPL v3.0

BKP_PATH=/var/backups
LOG_PATH=/var/log/backup.log

DB_HOST=localhost
DB_USER=db_user
DB_NAME=db_name

APP_PATH=/var/www/my_app
APP_NAME=my_app

echo "$(date -R) *** STARTING BACKUP" >> $LOG_PATH

echo "$(date -R) *** Starting DB dump" >> $LOG_PATH
mysqldump --single-transaction -h $DB_HOST -u $DB_USER $DB_NAME | gzip > $BKP_PATH/$DB_NAME.$(date +%Y%m%d).sql.gz

echo "$(date -R) *** Starting app backup" >> $LOG_PATH
tar cfz $BKP_PATH/$APP_NAME.$(date +%Y%m%d).tar.gz $APP_PATH/

echo "$(date -R) *** Starting old backups clean" >> $LOG_PATH
find $BKP_PATH/ -type f -mtime +7 -name '*.gz' -execdir rm {} \;

echo "$(date -R) *** BACKUP FINISHED" >> $LOG_PATH

