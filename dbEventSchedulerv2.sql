DELIMITER //

CREATE PROCEDURE RemoveOldData()
BEGIN
    SET @base_date = '2024-01-12';
    SET @cutoff_date = DATE_ADD(@base_date, INTERVAL -2 MONTH);
    SET @db_name = 'db';
    SET @table_name = 'tbl';
    
    SET @sql = CONCAT('DELETE FROM ', @db_name, '.', @table_name, ' WHERE DATET < "', @cutoff_date, '"');
    
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

END //
DELIMITER ;

CREATE EVENT RemoveOldDataEvent
ON SCHEDULE EVERY 1 DAY
DO
BEGIN
    CALL RemoveOldData();
END;
