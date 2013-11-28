#!/bin/sh

var_msg='整库备份'
echo ${var_msg}
var_date=`date "+%Y%m%d%H%M%S"`
db_ip=10.10.10.99
db_user=mysql
db_password=123456
game_db=game_db
game_user=game_user
game_count=game_count

echo ${var_msg}'开始'
/usr/local/mysql/bin/mysqldump -h${db_ip} -u${db_user} -p${db_password} \
 -B ${game_db} > ${game_db}_${var_date}.sql

/usr/local/mysql/bin/mysqldump -h${db_ip} -u${db_user} -p${db_password} \
 -B ${game_user} > ${game_user}_${var_date}.sql

/usr/local/mysql/bin/mysqldump -h${db_ip} -u${db_user} -p${db_password} \
 -B ${game_count} > ${game_count}_${var_date}.sql

echo ${var_msg}'完成'