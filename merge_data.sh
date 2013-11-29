#!/bin/sh

echo `date "+%Y-%m-%d %H:%M:%S"`': ''合并服务器数据'

# ==================== 变量定义 ====================
MYSQL_DUMP=`which mysqldump`
MYSQL=`which mysql`

var_current_path=`pwd`
echo '当前路径：'$var_current_path

# 原数据库
var_source_ip='10.10.10.22'
var_source_db='game_db_228'
var_source_user='mysql'
var_source_psw='123456'
var_source_systable_bak_file=$var_source_db'_systable_bak.sql'

# 目标数据库
var_target_ip='10.10.10.22'
var_target_db='game_db_229'
var_target_user='mysql'
var_target_psw='123456'

# 登录服数据库
var_login_ip='10.10.10.22'
var_login_db='game_user_246'
var_login_user='mysql'
var_login_psw='123456'

# ==================== 华丽的分割线 ====================
echo `date "+%Y-%m-%d %H:%M:%S"`': ''第零步 合服前，备份数据库'
$MYSQL_DUMP -h$var_source_ip -u$var_source_user -p$var_source_psw \
--skip-comments --compact --no-create-db --databases $var_source_db > $var_source_db'_source_bak.sql'

$MYSQL_DUMP -h$var_target_ip -u$var_target_user -p$var_target_psw \
--skip-comments --compact --no-create-db --databases $var_target_db > $var_target_db'_target_bak.sql'

echo `date "+%Y-%m-%d %H:%M:%S"`': ''第一步 合服迁移数据导出(在命令行执行)'
echo `date "+%Y-%m-%d %H:%M:%S"`': ''----数据清理：调用每个合服数据库的数据清理存储过程:call sp_hefu_clear() ----'
$MYSQL $var_source_db -h$var_source_ip -u$var_source_user -p$var_source_psw <<EOF
call sp_hefu_clear(1);
EOF

echo `date "+%Y-%m-%d %H:%M:%S"`': ''----系统数据表，（导系统数据）开始 ----'
$MYSQL_DUMP -h$var_source_ip -u$var_source_user -p$var_source_psw \
--databases $var_source_db --skip-comments --no-create-db \
--tables activity areas area_block area_scence \
build_class build_myget \
cd_type email_time giveprops \
hero hero_class hero_color hero_foster_class hero_get_war hero_great hero_refrish \
npc_group professional race \
role_log_type role_native_class role_renown_class role_vip skill \
skill_buff skill_buff_group sports_class sports_wins \
sys_equip sys_equip_gold sys_equip_group sys_equip_lv sys_explore sys_explore_npc sys_luck_bonus \
sys_luck_chance sys_prop_group sys_props sys_task sys_task_story \
task_group sys_pillage_base sys_active_bonus sys_npc sys_bonus sys_activity sys_activity_rebates \
sys_activity_purchase sys_activity_panicbuying sys_online_award sys_hunt_grid sys_extra_reward > $var_source_systable_bak_file
echo `date "+%Y-%m-%d %H:%M:%S"`': ''----系统数据表，（导系统数据）结束，导出文件：'$var_source_systable_bak_file'----'


# ==================== 华丽的分割线 ====================
echo `date "+%Y-%m-%d %H:%M:%S"`': ''第二步 将数据导入目标数据库'
echo `date "+%Y-%m-%d %H:%M:%S"`': ''----系统数据表，导入开始 ----'
$MYSQL $var_target_db -h$var_target_ip -u$var_target_user -p$var_target_psw < $var_source_systable_bak_file
$MYSQL $var_target_db -h$var_target_ip -u$var_target_user -p$var_target_psw <<EOF
call sp_hefu_clear(1);
quit;
EOF
echo `date "+%Y-%m-%d %H:%M:%S"`': ''----系统数据表，导入结束 ----'


# ==================== 华丽的分割线 ====================
echo `date "+%Y-%m-%d %H:%M:%S"`': ''第三步 执行存储过程进行数据处理 call sp_hefu();'
$MYSQL $var_target_db -h$var_target_ip -u$var_target_user -p$var_target_psw <<EOF
call sp_hefu();
quit;
EOF

# ==================== 华丽的分割线 ====================
echo `date "+%Y-%m-%d %H:%M:%S"`': ''第四步 手工修改登录服务器中被合服服务器的主机ip地址（host_group）'
$MYSQL $var_login_db -h$var_login_ip -u$var_login_user -p$var_login_psw <<EOF
update host_group set ip=$var_target_ip, lip=$var_target_ip, game_db=$var_target_db where ip=$var_source_ip and lip=$var_source_ip and game_db=$var_source_db;
commit;
quit;
EOF

# ==================== 华丽的分割线 ====================
echo `date "+%Y-%m-%d %H:%M:%S"`': ''服务器重启'