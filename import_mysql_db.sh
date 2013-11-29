#!/bin/sh

db_ip=10.10.10.22
db_user=root
db_password=123456
game_db=game_db
game_user=game_user
game_count=game_count

/usr/local/mysql/bin/mysql -h${db_ip} -u${db_user} -p${db_password} < ${game_user}.sql
/usr/local/mysql/bin/mysql -h${db_ip} -u${db_user} -p${db_password} < ${game_user}_systable.sql

/usr/local/mysql/bin/mysql -h${db_ip} -u${db_user} -p${db_password} < ${game_db}.sql
/usr/local/mysql/bin/mysql -h${db_ip} -u${db_user} -p${db_password} < ${game_db}_systable.sql

/usr/local/mysql/bin/mysql -h${db_ip} -u${db_user} -p${db_password} < ${game_count}.sql

# /usr/local/mysql/bin/mysql -h10.10.10.22 -umysql -p123456 < 