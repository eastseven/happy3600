#!/bin/sh

var_dbname=game_db
var_dbuser=mysql
var_dbpass=123456
var_dbhost=10.10.10.99

var_tmpdir=tmp

PWD=`pwd`
MYSQL=`which mysql`
MYSQLDUMP=`which mysqldump`

if [ -z "$MYSQLDUMP" ]; then
	MYSQLDUMP=/usr/local/mysql/bin/mysqldump
fi

if [ -z "$MYSQL" ]; then
	MYSQL=/usr/local/mysql/bin/mysql
fi

$MYSQLDUMP -h${var_dbhost} -u${var_dbuser} -p${var_dbpass} -n -t -d -R ${var_dbname} > $PWD/$var_tmpdir/${var_dbname}_sp.sql

var_dbname=game_count
$MYSQLDUMP -h${var_dbhost} -u${var_dbuser} -p${var_dbpass} -n -t -d -R ${var_dbname} > $PWD/$var_tmpdir/${var_dbname}_sp.sql

var_dbname=game_user
$MYSQLDUMP -h${var_dbhost} -u${var_dbuser} -p${var_dbpass} -n -t -d -R ${var_dbname} > $PWD/$var_tmpdir/${var_dbname}_sp.sql