#!/bin/bash
FILETMP=/tmp/mysql.processes

rm $FILETMP

mysql -uroot -paaaaa --disable-column-names  -e "select concat('KILL ',id,';') from information_schema.processlist where user='root' and time > 20 into outfile '$FILETMP'";

mysql -uroot -paaaaa --disable-column-names  -e "source $FILETMP";

mysql -uroot -paaaaa --disable-column-names  -e "show processlist";
