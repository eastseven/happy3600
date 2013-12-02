#!/bin/sh

echo `date "+%Y-%m-%d %H:%M:%S"`': ''合并服务器数据'

# ==================== 变量定义 ====================
MYSQL_DUMP=`which mysqldump`
MYSQL=`which mysql`

var_current_path=`pwd`
echo `date "+%Y-%m-%d %H:%M:%S"`': ''当前路径：'$var_current_path

var_hefu_sp=merge_data_procedure.sql

# 原数据库
var_source_ip=10.10.10.22
var_source_db=game_db_228
var_source_user=mysql
var_source_psw=123456
var_source_userdata=$var_source_db'_userdata_bak.sql'

# 目标数据库
var_target_ip=10.10.10.22
var_target_db=game_db_229
var_target_user=mysql
var_target_psw=123456

# 登录服数据库
var_login_ip=10.10.10.22
var_login_db=game_user_246
var_login_user=mysql
var_login_psw=123456

# ==================== 华丽的分割线 ====================
echo `date "+%Y-%m-%d %H:%M:%S"`': ''第零步 合服前，备份数据库'
#$MYSQL_DUMP -h$var_source_ip -u$var_source_user -p$var_source_psw \
#--skip-comments --compact --no-create-db --databases $var_source_db > $var_source_db'_source_bak.sql'

#MYSQL_DUMP -h$var_target_ip -u$var_target_user -p$var_target_psw \
#--skip-comments --compact --no-create-db --databases $var_target_db > $var_target_db'_target_bak.sql'

echo `date "+%Y-%m-%d %H:%M:%S"`': ''第零步 导入合服用存储过程'
$MYSQL $var_source_db -h$var_source_ip -u$var_source_user -p$var_source_psw < $var_hefu_sp
$MYSQL $var_target_db -h$var_target_ip -u$var_target_user -p$var_target_psw < $var_hefu_sp

echo `date "+%Y-%m-%d %H:%M:%S"`': ''第一步 合服迁移数据导出(在命令行执行)'
echo `date "+%Y-%m-%d %H:%M:%S"`': ''----数据清理：调用每个合服数据库的数据清理存储过程:call sp_hefu_clear() ----'
$MYSQL $var_source_db -h$var_source_ip -u$var_source_user -p$var_source_psw <<EOF
call sp_hefu_clear(1);
EOF
$MYSQL $var_target_db -h$var_target_ip -u$var_target_user -p$var_target_psw <<EOF
call sp_hefu_clear(1);
EOF

echo `date "+%Y-%m-%d %H:%M:%S"`': ''----用户数据表导出(主要用于合服)开始 ----'
$MYSQL_DUMP -h$var_source_ip -u$var_source_user -p$var_source_psw \
--databases $var_source_db --skip-comments --no-create-db --no-create-info \
--tables builds cd_queue email_receive email_send frdgroup friend hero_equip \
hero_foster hero_skill hero_train lvuprank message_family message_system message_user \
message_world mymessage role role_achieve role_backeg role_bonus role_castle role_data \
role_equip role_ext role_form role_goddess role_hero role_hero_bak role_hero_great role_hero_refrish \
role_luck role_log role_log_bmoney role_log_charm role_log_day role_log_war role_native role_present role_prop_use \
role_props role_renown role_scence role_sports role_sports_enemy role_task role_task_target role_explore leave leave_reply \
message_leave_word role_activities role_log_goods role_fb_invite hero_log > $var_source_userdata
#role_hunt_data role_hunt_item \
#role_hunt_log role_hunt_luck \
#> $var_source_userdata
echo `date "+%Y-%m-%d %H:%M:%S"`': ''----用户数据表导出(主要用于合服)，导出文件：'$var_source_userdata'----'


# ==================== 华丽的分割线 ====================
echo `date "+%Y-%m-%d %H:%M:%S"`': ''第二步 将数据导入目标数据库'
echo `date "+%Y-%m-%d %H:%M:%S"`': ''----用户数据表，导入开始 ----'
$MYSQL $var_target_db -h$var_target_ip -u$var_target_user -p$var_target_psw < $var_source_userdata
echo `date "+%Y-%m-%d %H:%M:%S"`': ''----用户数据表，导入结束 ----'


# ==================== 华丽的分割线 ====================
echo `date "+%Y-%m-%d %H:%M:%S"`': ''第三步 执行存储过程进行数据处理 call sp_hefu();'
$MYSQL $var_target_db -h$var_target_ip -u$var_target_user -p$var_target_psw <<EOF
call sp_hefu();
EOF


# ==================== 华丽的分割线 ====================
echo `date "+%Y-%m-%d %H:%M:%S"`': ''第四步 手工修改登录服务器中被合服服务器的主机ip地址（host_group）'
var_update_sql="update host_group set ip='${var_target_ip}', lip='${var_target_ip}', game_db='${var_target_db}' where ip='$var_source_ip' and lip='$var_source_ip' and game_db='$var_source_db';"
$MYSQL $var_login_db -h$var_login_ip -u$var_login_user -p$var_login_psw <<EOF
$var_update_sql ;
commit;

EOF

# ==================== 华丽的分割线 ====================
echo `date "+%Y-%m-%d %H:%M:%S"`': ''服务器重启'