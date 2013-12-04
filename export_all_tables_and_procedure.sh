#!/bin/sh

var_dbname=game_db
var_dbuser=mysql
var_dbpass=123456
var_dbhost=10.10.10.99

var_systable=`cat system_table.txt`

PWD=`pwd` 
MYSQL=`which mysql`
MYSQLDUMP=`which mysqldump`

if [ -z "$MYSQLDUMP" ]; then
	MYSQLDUMP=/usr/local/mysql/bin/mysqldump
fi

if [ -z "$MYSQL" ]; then
	MYSQL=/usr/local/mysql/bin/mysql
fi

var_all_table=game_db_all_table.sql
var_sysdata_file=game_db_sysdata.sql
var_tmpdir=tmp
rm -rf $var_tmpdir
mkdir $var_tmpdir

echo `date "+%Y-%m-%d %H:%M:%S"`': 导出游戏服表结构、存储过程' >> merge.log
$MYSQLDUMP -h${var_dbhost} -u${var_dbuser} -p${var_dbpass} -n -d -R ${var_dbname} > $PWD/$var_tmpdir/${var_all_table}
echo `date "+%Y-%m-%d %H:%M:%S"`': 导出游戏服系统数据' >> merge.log
$MYSQLDUMP -h${var_dbhost} -u${var_dbuser} -p${var_dbpass} -n -t ${var_dbname} ${var_systable} > $PWD/$var_tmpdir/${var_sysdata_file}

var_dbname=game_count
var_all_table=game_count_all_table.sql
var_sysdata_file=game_count_sysdata.sql
var_systable=`cat system_table_gamecount.txt`
echo `date "+%Y-%m-%d %H:%M:%S"`': 导出游戏服统计表结构、存储过程' >> merge.log
$MYSQLDUMP -h${var_dbhost} -u${var_dbuser} -p${var_dbpass} -n -d -R ${var_dbname} > $PWD/$var_tmpdir/${var_all_table}
echo `date "+%Y-%m-%d %H:%M:%S"`': 导出游戏服统计系统数据' >> merge.log
$MYSQLDUMP -h${var_dbhost} -u${var_dbuser} -p${var_dbpass} -n -t ${var_dbname} ${var_systable} > $PWD/$var_tmpdir/${var_sysdata_file}


var_dbname=game_user
var_systable=`cat system_table_gameuser.txt`
echo `date "+%Y-%m-%d %H:%M:%S"`': 导出登录服表结构、存储过程' >> merge.log
$MYSQLDUMP -h${var_dbhost} -u${var_dbuser} -p${var_dbpass} -n -d -R ${var_dbname} > $PWD/$var_tmpdir/${var_dbname}_all_table.sql

echo `date "+%Y-%m-%d %H:%M:%S"`': 导出登录服系统数据' >> merge.log
$MYSQLDUMP -h${var_dbhost} -u${var_dbuser} -p${var_dbpass} -n -t ${var_dbname} ${var_systable} > $PWD/$var_tmpdir/${var_dbname}_sysdata.sql

#var_dbname=game_db_002
#var_dbhost=10.10.10.99
#echo `date "+%Y-%m-%d %H:%M:%S"`': 导入游戏服表结构、存储过程' >> merge.log
#$MYSQL ${var_dbname} -h${var_dbhost} -u${var_dbuser} -p${var_dbpass} < $PWD/$var_tmpdir/${var_dbname}_exp.sql
#echo `date "+%Y-%m-%d %H:%M:%S"`': 导入游戏服系统数据' >> merge.log
#$MYSQL ${var_dbname} -h${var_dbhost} -u${var_dbuser} -p${var_dbpass} < $PWD/$var_tmpdir/${var_dbname}_sys_data.sql

#var_dbname=game_user
#echo `date "+%Y-%m-%d %H:%M:%S"`': 导入登录服表结构、存储过程'
#$MYSQL ${var_dbname} -h${var_dbhost} -u${var_dbuser} -p${var_dbpass} < $PWD/$var_tmpdir/${var_dbname}_exp.sql
#echo `date "+%Y-%m-%d %H:%M:%S"`': 导入登录服系统数据'
#$MYSQL ${var_dbname} -h${var_dbhost} -u${var_dbuser} -p${var_dbpass} < $PWD/$var_tmpdir/${var_dbname}_sys_data.sql

echo `date "+%Y-%m-%d %H:%M:%S"`': 完成'