SET GLOBAL event_scheduler = ON;

DELIMITER //
CREATE PROCEDURE RemoveOldData()
BEGIN
   DECLARE cutoff_date DATETIME;
    SET cutoff_date = DATE_SUB(NOW(), INTERVAL 2 MONTH);
    
    DECLARE done INT DEFAULT FALSE;
    DECLARE db_name VARCHAR(255);
    DECLARE cur CURSOR FOR SHOW DATABASES;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    db_loop: LOOP
        FETCH cur INTO db_name;
        IF done THEN
            LEAVE db_loop;
        END IF;
    
		DECLARE done_tables INT DEFAULT FALSE;
		DECLARE table_name VARCHAR(255);
		DECLARE cur_tables CURSOR FOR
			SELECT table_name
			FROM information_schema.tables
			WHERE table_schema = db_name;
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET done_tables = TRUE;
        
		OPEN cur_tables;
        
		table_loop: LOOP
			FETCH cur_tables INTO table_name;
			IF done_tables THEN
				LEAVE table_loop;
			END IF;
    
			SET @sql = CONCAT('DELETE FROM ', db_name, '.', table_name, ' WHERE DATET < "', DATE_FORMAT(cutoff_date, '%Y-%m-%d %H:%i:%s'), '"');
            
			PREPARE stmt FROM @sql;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
		END LOOP;
        
		CLOSE cur_tables;
	END LOOP;
    
    CLOSE cur;
    
END 


CREATE EVENT RemoveOldDataEvent
ON SCHEDULE EVERY 1 DAY
DO
BEGIN
    CALL RemoveOldData();
END;