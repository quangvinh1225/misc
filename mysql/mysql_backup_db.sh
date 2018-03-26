#!/bin/bash

#variable
databaseName=$1;
databaseHost='localhost';
databaseUsername='root';
databasePass='aaaaa';
MYSQL_PARAM="-h$databaseHost -u$databaseUsername -p$databasePass";

if [ -z $databaseName ]
then
        databaseName="ALL-LOCALHOST";
        MYSQL_PARAM="$MYSQL_PARAM --all-database";
else
        MYSQL_PARAM="$MYSQL_PARAM $databaseName";
fi


date=`eval date +%Y%m%d`;
backup_path="/vol/backup_mysql/$date";
filename="$databaseName"
filepath="$backup_path/$filename.sql";

echo "Backup database $databaseName";

#create backup path if it is not exist
if ! [ -d $backup_path ]
then
	mkdir -p $backup_path;
fi
if ! [ -d $backup_path ]
then
        echo "Error! Cannot create directory at $backup_path";
	exit;
fi

#create filename
c=1;
while [ -f $filepath ]
do
	filepath="$backup_path/$filename-$c.sql";
	(( c++ ));
done

#execute dump data
echo "$MYSQL_PARAM";
mysqldump $MYSQL_PARAM > "$filepath";
echo "Database \"$databaseName\" have been backup to $filepath";
