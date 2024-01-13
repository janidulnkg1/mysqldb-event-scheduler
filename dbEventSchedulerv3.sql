DELIMITER //

CREATE PROCEDURE RemoveOldData()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN

        SELECT 'An error occurred!';
    END;

    SET @base_date = 'YYYY-MM-DD';
    SET @cutoff_date = DATE_ADD(@base_date, INTERVAL -2 MONTH);
    SET @db_name = 'dbName';
    SET @table_name = 'tblName';


    IF EXISTS (SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = @db_name) THEN
        IF EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = @db_name AND TABLE_NAME = @table_name) THEN
            SET @sql = CONCAT('DELETE FROM ', @db_name, '.', @table_name, ' WHERE DATET < ''', @cutoff_date, '''');
        
            PREPARE stmt FROM @sql;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
        ELSE
            SELECT 'Table does not exist!';
        END IF;
    ELSE
        SELECT 'Database does not exist!';
    END IF;
END //
DELIMITER ;

CREATE EVENT RemoveOldDataEvent
ON SCHEDULE EVERY 1 DAY
DO
BEGIN
    CALL RemoveOldData();
END;
