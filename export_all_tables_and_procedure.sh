#!/bin/sh

var_dbname=game_db
var_dbuser=mysql
var_dbpass=123456
var_dbhost=10.10.10.99

var_systable=`cat system_table.txt`

MYSQL=`which mysql`
MYSQLDUMP=`which mysqldump`

echo `date "+%Y-%m-%d %H:%M:%S"`': 导出游戏服表结构、存储过程'
$MYSQLDUMP -h${var_dbhost} -u${var_dbuser} -p${var_dbpass} -n -d -R ${var_dbname} > ${var_dbname}_exp.sql

echo `date "+%Y-%m-%d %H:%M:%S"`': 导出游戏服系统数据'
$MYSQLDUMP -h${var_dbhost} -u${var_dbuser} -p${var_dbpass} -n -t ${var_dbname} ${var_systable} > ${var_dbname}_sys_data.sql

var_dbname=game_user
var_systable=`cat system_table_gameuser.txt`
echo `date "+%Y-%m-%d %H:%M:%S"`': 导出登录服表结构、存储过程'
$MYSQLDUMP -h${var_dbhost} -u${var_dbuser} -p${var_dbpass} -n -d -R ${var_dbname} > ${var_dbname}_exp.sql

echo `date "+%Y-%m-%d %H:%M:%S"`': 导出登录服系统数据'
$MYSQLDUMP -h${var_dbhost} -u${var_dbuser} -p${var_dbpass} -n -t ${var_dbname} ${var_systable} > ${var_dbname}_sys_data.sql
