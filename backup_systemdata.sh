#!/bin/sh

source ~/.profile

db_ip=10.10.10.99
db_user=mysql
db_password=123456
game_db=game_db
game_user=game_user
game_count=game_count

# ==================== 变量定义 ====================
MYSQL=`which mysql`
MYSQLDUMP=`which mysqldump`
PWD=`pwd`

if [ -z "$MYSQLDUMP" ]; then
	MYSQLDUMP=/usr/local/mysql/bin/mysqldump
fi

if [ -z "$MYSQL" ]; then
	MYSQL=/usr/local/mysql/bin/mysql
fi

var_tmpdir=tmp
var_systable=`cat system_table.txt`
var_version=`date "+%Y%m%d-%H%M%S"`

echo `date "+%Y-%m-%d %H:%M:%S"`': 导出系统表及数据 开始'

$MYSQLDUMP -h${db_ip} -u${db_user} -p${db_password} ${game_db} ${var_systable} > $PWD/$var_tmpdir/${game_db}_${var_version}.sql

echo `date "+%Y-%m-%d %H:%M:%S"`': 导出系统表及数据 结束'