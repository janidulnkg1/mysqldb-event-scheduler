DELIMITER //

CREATE PROCEDURE RemovalOfVeryOldData()
BEGIN
    DECLARE base_date DATE;
    DECLARE cutoff_date DATE;
    DECLARE db_name VARCHAR(255);
    DECLARE table_name VARCHAR(255);
    DECLARE column_date VARCHAR(255);
    DECLARE query VARCHAR(1000); -- Adjust size as per your requirement

    SET base_date = '2005-07-07';
    SET cutoff_date = DATE_ADD(base_date, INTERVAL -1 MONTH);
    SET db_name = 'sakila';
    SET table_name = 'payment';
    SET column_date = 'payment_date'; 

    IF EXISTS (SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = db_name) THEN
        IF EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = db_name AND TABLE_NAME = table_name) THEN
            SET @query = CONCAT('DELETE FROM ', db_name, '.', table_name, ' WHERE ', column_date, ' < "', cutoff_date, '"');
            PREPARE stmt FROM @query;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
        ELSE
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Table does not exist!';
        END IF;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Database does not exist!';
    END IF;
END //

DELIMITER ;

CALL RemovalOfVeryOldData();




