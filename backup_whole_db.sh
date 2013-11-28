#!/bin/sh

var_msg='整库备份'
echo `date "+%Y-%m-%d %H:%M:%S"`': '${var_msg}
var_date=`date "+%Y_%m_%d_%H_%M_%S"`
db_ip=10.10.10.99
db_user=mysql
db_password=123456
game_db=game_db
game_user=game_user
game_count=game_count

echo `date "+%Y-%m-%d %H:%M:%S"`': '${var_msg}'开始'

echo '\n'`date "+%Y-%m-%d %H:%M:%S"`': GAME_DB'
/usr/local/mysql/bin/mysqldump -h${db_ip} -u${db_user} -p${db_password} \
 -B -R ${game_db} > ${game_db}_${var_date}.sql

echo '\n'`date "+%Y-%m-%d %H:%M:%S"`': GAME_USER'
/usr/local/mysql/bin/mysqldump -h${db_ip} -u${db_user} -p${db_password} \
 -B -R ${game_user} > ${game_user}_${var_date}.sql

echo '\n'`date "+%Y-%m-%d %H:%M:%S"`': GAME_COUNT'
/usr/local/mysql/bin/mysqldump -h${db_ip} -u${db_user} -p${db_password} \
 -B -R ${game_count} > ${game_count}_${var_date}.sql

echo ${var_msg}'完成'

# /usr/local/mysql/bin/mysqldump -h10.10.10.99 -umysql -p123456 --opt db_name > backup-file.sql