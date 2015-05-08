#!/bin/bash
set -e

DBNAME=$1
echo "Truncating $DBNAME"
DATE=`date +%m%d%H%M`
mysqldump --no-data -uroot -pAesx5099 $DBNAME > tmp_truncate_${DBNAME}_${DATE}.sql
mysql -uroot -pAesx5099 -e "drop database \`$DBNAME\`;"
mysql -uroot -pAesx5099 -e "create database \`$DBNAME\`;"
mysql -uroot -pAesx5099 $DBNAME < tmp_truncate_${DBNAME}_${DATE}.sql
rm tmp_truncate_${DBNAME}_${DATE}.sql
