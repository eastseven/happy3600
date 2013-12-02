
DELIMITER $$

CREATE PROCEDURE IF EXISTS `sp_hefu`()
BEGIN
	call sp_hefu_user_area();
	CALL sp_hefu_role_sports();
END $$

CREATE PROCEDURE IF EXISTS `sp_hefu_clear`(
	p_backup tinyint
)
BEGIN
	DECLARE cur_time datetime DEFAULT now();
	declare today varchar(10) default '';
	set today =DATE_FORMAT(cur_time ,"%Y-%m-%d");
	
	-- role_task role_task_target
	/*
	if(p_backup > 0) then
		create table if not exists zbak_role_task like role_task;	
		ALTER TABLE `zbak_role_task` DROP PRIMARY KEY;	
		CREATE TABLE IF NOT EXISTS zbak_role_task_target LIKE role_task_target;	
		
		insert into zbak_role_task select * from role_task where `status`>3;
		insert into zbak_role_task_target SELECT * FROM role_task_target WHERE my_tid in(select my_tid from role_task where `status`>3);
	end if;
	*/
	-- DELETE FROM role_task WHERE `status`>3;
	
	-- role_log_bmoney
	IF(p_backup > 0) THEN
		CREATE TABLE IF NOT EXISTS zbak_role_log_bmoney LIKE role_log_bmoney;	
		INSERT INTO zbak_role_log_bmoney SELECT * FROM role_log_bmoney WHERE btime<today;
	end if;
	DELETE FROM role_log_bmoney WHERE btime<today;
	
	-- role_log_day
	IF(p_backup > 0) THEN
		CREATE TABLE IF NOT EXISTS zbak_role_log_day LIKE role_log_day;	
		INSERT INTO zbak_role_log_day (SELECT * FROM role_log_day where tday<today);
	end if;
	DELETE FROM role_log_day WHERE tday<today;
	
	-- role_log
	IF(p_backup > 0) THEN
		CREATE TABLE IF NOT EXISTS zbak_role_log LIKE role_log;	
		INSERT INTO zbak_role_log (SELECT * FROM role_log WHERE ctime<today);
	end if;
	DELETE FROM role_log WHERE ctime<today;
	
	-- cd_queue
	DELETE FROM cd_queue WHERE isend>0;
	DELETE FROM cd_queue WHERE FROM_UNIXTIME(`start` + `wait`) < cur_time;
	
	truncate email_receive;
	truncate email_send;
	truncate message_family;
	truncate message_system;
	truncate message_user;
	truncate message_world;

	truncate `leave`;
	truncate leave_reply;
	truncate role_log_charm;
	/**清理消息*/
END $$

CREATE PROCEDURE IF EXISTS `sp_hefu_role_sports`()
BEGIN
	DECLARE t_rank INT DEFAULT -1;
	DECLARE is_has BOOL DEFAULT TRUE;
	DECLARE t_uid INT DEFAULT -1;
	DECLARE cur1 CURSOR FOR SELECT r.uid FROM role r,role_sports s where r.uid=s.uid order by s.rank,r.all_eval desc;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET is_has = FALSE;
	
	SET t_rank = 1;
	OPEN cur1;
	FETCH cur1 INTO t_uid;
	WHILE(is_has) DO
		UPDATE role_sports SET rank=t_rank WHERE uid=t_uid;
		SET t_rank = t_rank + 1;
		FETCH cur1 INTO t_uid;
	END WHILE;
	CLOSE cur1;
END $$

CREATE PROCEDURE IF EXISTS `sp_hefu_user_area`()
BEGIN
	DECLARE t_pos INT DEFAULT -1;
	DECLARE is_has BOOL DEFAULT TRUE;
	DECLARE t_area INT DEFAULT -1;
	DECLARE cur1 CURSOR FOR SELECT distinct areaid FROM role_castle;	
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET is_has = FALSE;
		
	OPEN cur1;
	FETCH cur1 INTO t_area;
	WHILE(is_has) DO
		set @t_pos = 1;
		update role_castle set posx=(@t_pos:=@t_pos+1) where areaid=t_area order by uid;
		FETCH cur1 INTO t_area;
	END WHILE;
	CLOSE cur1;
END $$

DELIMITER ;
