#!/bin/sh

echo `date "+%Y-%m-%d %H:%M:%S"`': ''合并服务器数据' >> merge.log

# ==================== 变量定义 ====================
MYSQL_DUMP=`which mysqldump`
MYSQL=`which mysql`

var_current_path=`pwd`
echo `date "+%Y-%m-%d %H:%M:%S"`': ''当前路径：'$var_current_path >> merge.log

var_hefu_sp=merge_data_procedure.sql

# 原数据库
var_source_ip=10.10.10.99
var_source_db=game_db_001
var_source_user=mysql
var_source_psw=123456
var_source_userdata=source_db_userdata_bak.sql
var_usertable=`cat user_table.txt`
var_source_sockport=17701
var_source_httpport=17801

# 目标数据库
var_target_ip=10.10.10.99
var_target_db=game_db_002
var_target_user=mysql
var_target_psw=123456
var_target_sockport=27701
var_target_httpport=27801

# 登录服数据库
var_login_ip=10.10.10.99
var_login_db=game_user_000
var_login_user=mysql
var_login_psw=123456

# ==================== 华丽的分割线 ====================
echo `date "+%Y-%m-%d %H:%M:%S"`': ''第零步 合服前，备份数据库' >> merge.log
$MYSQL_DUMP -h$var_source_ip -u$var_source_user -p$var_source_psw --skip-comments --compact --no-create-db --databases $var_source_db > ${var_source_db}'_source_bak.sql'

$MYSQL_DUMP -h$var_target_ip -u$var_target_user -p$var_target_psw --skip-comments --compact --no-create-db --databases $var_target_db > ${var_target_db}'_target_bak.sql'

echo `date "+%Y-%m-%d %H:%M:%S"`': ''第零步 合服前source库UID数据' >> merge.log
$MYSQL $var_source_db -h$var_source_ip -u$var_source_user -p$var_source_psw <<EOF
select count(uid) from role;
EOF
echo `date "+%Y-%m-%d %H:%M:%S"`': ''第零步 合服前target库UID数据' >> merge.log
$MYSQL $var_target_db -h$var_target_ip -u$var_target_user -p$var_target_psw <<EOF
select count(uid) from role;
EOF
echo `date "+%Y-%m-%d %H:%M:%S"`': ''第零步 合服前target库中重复source库中的UID数据' >> merge.log
$MYSQL -h$var_target_ip -u$var_target_user -p$var_target_psw <<EOF
select r8.uid from $var_source_db.role r8 where exists (select 1 from $var_target_db.role r9 where r8.uid = r9.uid);
EOF

echo `date "+%Y-%m-%d %H:%M:%S"`': ''第一步 合服迁移数据导出(在命令行执行)' >> merge.log
echo `date "+%Y-%m-%d %H:%M:%S"`': ''----数据清理：调用每个合服数据库的数据清理存储过程:call sp_hefu_clear() ----' >> merge.log
$MYSQL $var_source_db -h$var_source_ip -u$var_source_user -p$var_source_psw <<EOF
call sp_hefu_clear(1);
EOF
$MYSQL $var_target_db -h$var_target_ip -u$var_target_user -p$var_target_psw <<EOF
call sp_hefu_clear(1);
EOF

echo `date "+%Y-%m-%d %H:%M:%S"`': ''----用户数据表导出(主要用于合服)开始 ----' >> merge.log
$MYSQL_DUMP -h$var_source_ip -u$var_source_user -p$var_source_psw --databases $var_source_db --skip-comments --no-create-db --no-create-info --tables ${var_usertable} > $var_source_userdata
echo `date "+%Y-%m-%d %H:%M:%S"`': ''----用户数据表导出(主要用于合服)，导出文件：'$var_source_userdata'----' >> merge.log


# ==================== 华丽的分割线 ====================
echo `date "+%Y-%m-%d %H:%M:%S"`': ''第二步 将数据导入目标数据库' >> merge.log
echo `date "+%Y-%m-%d %H:%M:%S"`': ''----用户数据表，导入开始 ----' >> merge.log
$MYSQL $var_target_db -h$var_target_ip -u$var_target_user -p$var_target_psw < $var_source_userdata
echo `date "+%Y-%m-%d %H:%M:%S"`': ''----用户数据表，导入结束 ----' >> merge.log


# ==================== 华丽的分割线 ====================
echo `date "+%Y-%m-%d %H:%M:%S"`': ''第三步 执行存储过程进行数据处理 call sp_hefu();' >> merge.log
$MYSQL $var_target_db -h$var_target_ip -u$var_target_user -p$var_target_psw <<EOF
call sp_hefu();
EOF


# ==================== 华丽的分割线 ====================
echo `date "+%Y-%m-%d %H:%M:%S"`': ''第四步 手工修改登录服务器中被合服服务器的主机ip地址（host_group）' >> merge.log
var_update_sql="update host_group set ip='${var_target_ip}', lip='${var_target_ip}', game_db='${var_target_db}', sock_port='${var_target_sockport}', http_port='${var_target_httpport}' where ip='$var_source_ip' and lip='$var_source_ip' and game_db='$var_source_db';"
$MYSQL $var_login_db -h$var_login_ip -u$var_login_user -p$var_login_psw <<EOF
$var_update_sql ;
commit;

EOF

# ==================== 华丽的分割线 ====================
echo `date "+%Y-%m-%d %H:%M:%S"`': ''第五步 合服后target库UID数据' >> merge.log
$MYSQL $var_target_db -h$var_target_ip -u$var_target_user -p$var_target_psw <<EOF
select count(uid) from role;
EOF

# ==================== 华丽的分割线 ====================
echo `date "+%Y-%m-%d %H:%M:%S"`': ''服务器重启' >> merge.log