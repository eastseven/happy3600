#!/bin/sh

db_ip=10.10.10.99
db_user=mysql
db_password=123456
game_db=game_db
game_user=game_user
game_count=game_count

var_date=`date "+%Y%m%d%H%M%S"`

echo '导出GAME_DB系统表'
/usr/local/mysql/bin/mysqldump \ 
-h${db_ip} \ 
-u${db_user} \ 
-p${db_password} \ 
--databases ${game_db} \ 
--skip-comments \ 
--no-create-db \ 
--tables \ 
activity areas area_block area_scence build_class build_myget \ 
cd_type email_time giveprops hero hero_class hero_color hero_foster_class \ 
hero_get_war hero_great hero_refrish npc_group professional race \ 
role_log_type role_native_class role_renown_class role_vip skill \ 
skill_buff skill_buff_group sports_class sports_wins sys_equip \ 
sys_equip_gold sys_equip_group sys_equip_lv sys_explore sys_explore_npc \ 
sys_luck_bonus sys_luck_chance sys_prop_group sys_props sys_task \ 
sys_task_story task_group sys_pillage_base sys_active_bonus sys_npc \ 
sys_bonus sys_activity sys_activity_rebates sys_activity_purchase \ 
sys_activity_panicbuying sys_online_award sys_hunt_grid sys_extra_reward > game_db_systable_${var_date}.sql

echo '导出GAME_USER系统表'
/usr/local/mysql/bin/mysqldump -h${db_ip} -u${db_user} -p${db_password} \ 
--databases ${game_user} --skip-comments --no-create-db --tables \ 
tb_sysmodule tb_user tb_role > game_user_systable_${var_date}.sql

echo '导出整库game_db,game_user,game_count，包括存储过程'
/usr/local/mysql/bin/mysqldump -h${db_ip} -u${db_user} -p${db_password} \ 
--routines --no-data --add-drop-database -B ${game_user}  > ${game_user}_${var_date}.sql

/usr/local/mysql/bin/mysqldump -h${db_ip} -u${db_user} -p${db_password} \ 
--routines --no-data --add-drop-database -B ${game_db}    > ${game_db}_${var_date}.sql

/usr/local/mysql/bin/mysqldump -h${db_ip} -u${db_user} -p${db_password} \ 
--routines --no-data --add-drop-database -B ${game_count} > ${game_count}_${var_date}.sql

echo '完成'