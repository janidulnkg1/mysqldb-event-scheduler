DELIMITER //

CREATE PROCEDURE RemoveOldDatedData()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT 'An error occurred!';
    END;

    SET @base_date = '2005-05-27';
    SET @cutoff_date = DATE_ADD(@base_date, INTERVAL -1 MONTH);
    SET @db_name = 'sakila';
    SET @table_name = 'payment';
    SET @column_date = 'payment_date'; -- Assigning 'DATET' to variable @column_date

    IF EXISTS (SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = @db_name) THEN
        IF EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = @db_name AND TABLE_NAME = @table_name) THEN
            SET @sql = CONCAT('DELETE FROM ', @db_name, '.', @table_name, ' WHERE ', @column_date, ' < ''', @cutoff_date, '''');
        
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


CALL RemoveOldDatedData();

